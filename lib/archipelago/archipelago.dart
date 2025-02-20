library;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:stream_channel/stream_channel.dart';

import 'client_to_server.dart' as client;
import 'protocol_types.dart';
import 'server_to_client.dart' as server;

/// Controller class for an Archipelago connection.
/// Encapsulates all the state required for an Archipelago connection.
final class ArchipelagoClient {
  final ArchipelagoConnector _connection;
  final _ArchipelagoClientInfo _currentClientInfo;
  final _ArchipelagoRoomInfo _currentRoomInfo;
  final int team;
  final int slot;
  final List<int> missingLocations;
  final List<int> checkedLocations;
  final Map<String, dynamic>? slotData;
  final Map<int, NetworkSlot> slotInfo;
  int hintPoints;

  final server.RoomInfo _roomInfo;

  Permission get releasePermission => _roomInfo.release;
  Permission get collectPermission => _roomInfo.collect;
  Permission get remainingPermission => _roomInfo.remaining;
  List<String> get roomTags => _roomInfo.tags;
  int get hintCost => _roomInfo.hintCost;

  List<String> get clientTags => _currentClientInfo.tags;

  bool get receiveOtherWorld => _currentClientInfo.receiveOtherWorld;
  bool get receiveOwnWorld => _currentClientInfo.receiveOwnWorld;
  bool get receiveStartingInventory =>
      _currentClientInfo.receiveStartingInventory;

  ArchipelagoClient._(
    this._connection,
    this._currentClientInfo,
    this._currentRoomInfo,
    this._roomInfo,
    this.team,
    this.slot,
    this.missingLocations,
    this.checkedLocations,
    this.slotData,
    this.slotInfo,
    this.hintPoints,
  );

  static Future<ArchipelagoClient> connect(
    StreamChannel channel,
    ArchipelagoClientSettings clientSettings,
    String uuid,
    String userName, [
    String password = '',
    DataPackageHandler? dataPackageHandler,
  ]) async {
    ArchipelagoConnector connection = ArchipelagoConnector(channel);
    return ArchipelagoClient._handshake(
      clientSettings,
      connection,
      userName,
      password,
      uuid,
      dataPackageHandler,
    );
  }

  static Future<ArchipelagoClient> connectUsingConnector(
    ArchipelagoConnector connector,
    ArchipelagoClientSettings clientSettings,
    String userName,
    String uuid, [
    String password = '',
    DataPackageHandler? dataPackageHandler,
  ]) async {
    return ArchipelagoClient._handshake(
      clientSettings,
      connector,
      userName,
      password,
      uuid,
      dataPackageHandler,
    );
  }

  static Future<ArchipelagoClient> _handshake(
    ArchipelagoClientSettings clientSettings,
    ArchipelagoConnector connector,
    String userName,
    String password,
    String uuid, [
    DataPackageHandler? dataPackageHandler,
  ]) async {
    final stream = connector.stream;

    final queue = _MessageQueue();
    final queueStreamController = stream.listen(
      (event) => queue.addMessage(event),
    );

    final server.ServerMessage roomInfo = await queue.getMessage();
    if (roomInfo is! server.RoomInfo) {
      throw HandshakeException(HandshakeExceptionType.didNotRecieveRoomInfo);
    }

    if (dataPackageHandler != null) {
      final games = dataPackageHandler.selectGames(roomInfo);
      connector.send(client.GetDataPackage(games));
      final server.ServerMessage dataPackage = await queue.getMessage();
      if (dataPackage is! server.DataPackage) {
        throw HandshakeException(
          HandshakeExceptionType.didNotRecieveDataPackage,
        );
      }
      dataPackageHandler.handleDataPackage(dataPackage);
    }

    connector.send(
      client.Connect(
        roomInfo.password ? password : null,
        clientSettings.game,
        userName,
        uuid,
        _ArchipelagoGlobal.supportedVersion,
        clientSettings.itemFlags.otherWorlds,
        clientSettings.itemFlags.ownWorld,
        clientSettings.itemFlags.startingInventory,
        clientSettings.tags,
        clientSettings.receiveSlotData,
      ),
    );

    final server.ServerMessage connected = await queue.getMessage();
    // Stop sending messages to the queue, we've either succeeded or failed by now.
    queueStreamController.cancel();

    if (connected is server.ConnectionRefused) {
      throw ArchipelagoConnectionRefused(connected.errors);
    } else if (connected is! server.Connected) {
      throw HandshakeException(
        HandshakeExceptionType.didNotRecieveConnectionResponse,
      );
    }

    return ArchipelagoClient._(
      connector,
      _ArchipelagoClientInfo(
        clientSettings.itemFlags.otherWorlds,
        clientSettings.itemFlags.ownWorld,
        clientSettings.itemFlags.startingInventory,
        clientSettings.tags,
      ),
      _ArchipelagoRoomInfo(connected.players, connected.checkedLocations),
      roomInfo,
      connected.team,
      connected.slot,
      connected.missingLocations,
      connected.checkedLocations,
      connected.slotData,
      connected.slotInfo,
      connected.hintPoints,
    );
  }

  /// Apply a RoomUpdate message.
  /// This has to be done manually, as there's no nice, universal way to do this and notify any dependents, so the user just has to solve it on their own.
  void updateRoomInfo(server.RoomUpdate update) {
    final players = update.players;
    final checkedLocations = update.checkedLocations;
    if (players != null) {
      _currentRoomInfo.updatePlayerList(players);
    }
    if (checkedLocations != null) {
      _currentRoomInfo.updateCheckedLocations(checkedLocations);
    }
  }

  void sendMessage(client.ClientMessage message) {
    _connection.send(message);
  }
}

/// A queue to hold messages and return them asynchronously.
/// ONLY USE DURING THE HANDSHAKE.
final class _MessageQueue {
  final Queue<server.ServerMessage> _queue = Queue();
  Completer<server.ServerMessage>? _waiting;

  void addMessage(server.ServerMessage message) {
    if (_waiting == null) {
      _queue.add(message);
    } else {
      _waiting!.complete(message);
      _waiting = null;
    }
  }

  Future<server.ServerMessage> getMessage() async {
    if (_queue.isEmpty) {
      // This doesn't actually make anything safer
      _waiting ??= Completer();
      return _waiting!.future;
    } else {
      return Future.value(_queue.removeFirst());
    }
  }
}

/// Globally available utilities for Archipelago connections.
abstract class _ArchipelagoGlobal {
  /// Hold onto the UUID generator.
  static Uuid? _uuidGenerator;

  /// Generate a UUID
  static String generateUUID() {
    _ArchipelagoGlobal._uuidGenerator ??= Uuid();
    return _uuidGenerator!.v4();
  }

  /// The supported version of Archipelago
  static NetworkVersion get supportedVersion {
    return NetworkVersion(0, 5, 1);
  }
}

/// Application-facing connection settings.
class ArchipelagoClientSettings {
  final String? game;
  final List<String> tags;
  final client.ItemsHandlingFlags itemFlags;
  final bool receiveSlotData;

  const ArchipelagoClientSettings._(
    this.game,
    this.tags,
    this.itemFlags,
    this.receiveSlotData,
  );

  factory ArchipelagoClientSettings({
    String? game,
    List<String>? tags,
    bool receiveOtherWorlds = false,
    bool receiveOwnWorld = false,
    bool receiveStartingInventory = false,
    bool receiveSlotData = false,
  }) {
    if (game == null &&
        (tags == null ||
            !tags.contains('HintGame') ||
            !tags.contains('Tracker') ||
            !tags.contains('TextOnly'))) {
      throw Error();
    }
    if ((receiveOwnWorld || receiveStartingInventory) && receiveOtherWorlds) {
      throw Error();
    }
    return ArchipelagoClientSettings._(
      game,
      tags ?? [],
      client.ItemsHandlingFlags(
        receiveOtherWorlds,
        receiveOwnWorld,
        receiveStartingInventory,
      ),
      receiveSlotData,
    );
  }
}

class ArchipelagoConnector {
  final StreamChannel _channel;
  final StreamSink _sink;
  final Stream<server.ServerMessage> stream;

  ArchipelagoConnector._(this._channel, this._sink, this.stream);

  factory ArchipelagoConnector(StreamChannel channel) {
    final stream =
        channel.stream
            .map((event) => jsonDecode(event) as List<dynamic>)
            .expand((x) => x)
            .map((event) => jsonDecode(event) as server.ServerMessage)
            .asBroadcastStream();
    final StreamSink sink = channel.sink;
    return ArchipelagoConnector._(channel, sink, stream);
  }

  void send(client.ClientMessage message) {
    _sink.add(jsonEncode([message]));
  }
}

final class HandshakeException implements Exception {
  final HandshakeExceptionType type;
  final String? description;
  HandshakeException(this.type, [this.description]);
}

final class ArchipelagoConnectionRefused implements Exception {
  final List<server.ConnectionRefusedReason>? errors;
  ArchipelagoConnectionRefused(this.errors);
}

enum HandshakeExceptionType {
  didNotRecieveRoomInfo,
  didNotRecieveDataPackage,
  didNotRecieveConnectionResponse,
}

final class _ArchipelagoRoomInfo {
  List<NetworkPlayer> _players;
  final Set<int> _checkedLocations;

  _ArchipelagoRoomInfo(this._players, List<int> checkedLocations)
    : _checkedLocations = checkedLocations.fold<Set<int>>(<int>{}, (set, x) {
        set.add(x);
        return set;
      });

  UnmodifiableSetView<int> get checkedLocations =>
      UnmodifiableSetView(_checkedLocations);

  void updateCheckedLocations(List<int> newLocations) {
    newLocations.fold(_checkedLocations, (set, x) {
      set.add(x);
      return set;
    });
  }

  UnmodifiableListView<NetworkPlayer> get players =>
      UnmodifiableListView(_players);

  void updatePlayerList(List<NetworkPlayer> players) {
    _players = players;
  }
}

final class _ArchipelagoClientInfo {
  bool _receiveOtherWorld;
  bool get receiveOtherWorld => _receiveOtherWorld;
  bool _receiveOwnWorld;
  bool get receiveOwnWorld => _receiveOwnWorld;
  bool _receiveStartingInventory;
  bool get receiveStartingInventory => _receiveStartingInventory;
  List<String> tags;

  void setItemHandlingFlags(bool other, bool own, bool starting) {
    if ((own || starting) && !other) {
      Error();
    }
    _receiveOtherWorld = other;
    _receiveOwnWorld = own;
    _receiveStartingInventory = starting;
  }

  client.ConnectUpdate get updateMessage => client.ConnectUpdate(
    client.ItemsHandlingFlags(
      receiveOtherWorld,
      receiveOwnWorld,
      receiveStartingInventory,
    ),
    tags,
  );

  _ArchipelagoClientInfo(
    this._receiveOtherWorld,
    this._receiveOwnWorld,
    this._receiveStartingInventory,
    this.tags,
  );
}

abstract interface class DataPackageHandler {
  List<String> selectGames(server.RoomInfo roomInfo);
  Future<void> handleDataPackage(server.DataPackage dataPackage);
}
