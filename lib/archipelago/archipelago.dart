library;

import 'dart:collection';

import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'client_to_server.dart' as client;
import 'protocol_types.dart';
import 'server_to_client.dart' as server;

/// Controller class for an Archipelago connection.
/// Encapsulates all the state required for an Archipelago connection.
final class ArchipelagoClient {
  final _ArchipelagoConnection _connection;
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
    ArchipelagoClientSettings clientSettings,
    ArchipelagoConnectionSettings connectionSettings, [
    DataPackageHandler? dataPackageHandler,
  ]) async {
    final connection = await _ArchipelagoConnection.connect(connectionSettings);
    final stream = connection.stream;
    server.RoomInfo? roomInfo;
    server.DataPackage? dataPackage;
    server.ServerMessage? connected;
    _HandshakeStep handShakeStep = _HandshakeStep.roomInfo;
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
}

enum _HandshakeStep { roomInfo, dataPackage, connection }

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

/// User-facing connection settings.
/// While these settings required aren't enough to do anything alone, they are the ones more likely to change regularly.
class ArchipelagoConnectionSettings {
  final Uri uri;
  final String userName;
  final String password;

  ArchipelagoConnectionSettings._(this.uri, this.userName, this.password);

  factory ArchipelagoConnectionSettings({
    required String address,
    required int port,
    required String userName,
    String password = '',
  }) {
    final uri = Uri(host: address, port: port, scheme: 'ws');

    return ArchipelagoConnectionSettings._(uri, userName, password);
  }
}

/// Application-facing connection settings.
/// [ArchipelagoConnectionSettings] are still required to do anything, but these are settings typically set by the application and not changed by the user.
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

  const ArchipelagoClientSettings.constConstructor(
    this.game,
    this.tags,
    this.itemFlags,
    this.receiveSlotData,
  );
}

class _ArchipelagoConnection {
  final WebSocketChannel _channel;
  final WebSocketSink _sink;
  final Stream<server.ServerMessage> stream;
  final String clientUUID;
  final ArchipelagoConnectionSettings connectionInfo;

  _ArchipelagoConnection._(
    this._channel,
    this._sink,
    this.stream,
    this.clientUUID,
    this.connectionInfo,
  );

  static Future<_ArchipelagoConnection> connect(
    ArchipelagoConnectionSettings connectionInfo,
  ) async {
    // TODO: Rewrite this
    final channel = WebSocketChannel.connect(connectionInfo.uri);
    // Get the stream from the socket, interpret the packets, and make it a broadcast.
    final stream =
        channel.stream
            .map((event) => server.ServerMessage.fromJson(event))
            .asBroadcastStream();
    // Wait until it's actually ready
    await channel.ready;

    final WebSocketSink sink = channel.sink;

    final uuid = _ArchipelagoGlobal.generateUUID();

    return _ArchipelagoConnection._(
      channel,
      sink,
      stream,
      uuid,
      connectionInfo,
    );
  }

  Future<ArchipelagoClient> handshake([
    DataPackageHandler? dataPackageHandler,
  ]) async {
    // We need to keep track of how many of the first messages to skip.
    int messageSkip = 0;

    // Get the first message.
    final server.ServerMessage roomInfo = await stream.first;

    if (roomInfo is! server.RoomInfo) {
      throw HandshakeException(HandshakeExceptionType.didNotRecieveRoomInfo);
    }

    // If a handler is provided, ask for the data package
    if (dataPackageHandler != null) {
      var players = dataPackageHandler.selectGames(roomInfo);
      send(client.GetDataPackage(players));

      // Get the second message by skipping the first and grabbing the new first.
      final server.ServerMessage dataPackage =
          await stream.skip(++messageSkip).first;

      if (dataPackage is! server.DataPackage) {
        throw HandshakeException(
          HandshakeExceptionType.didNotRecieveDataPackage,
        );
      }
      await dataPackageHandler.handleDataPackage(dataPackage);
    }

    send(
      client.Connect(
        roomInfo.password ? connectionInfo.password : null,
        connectionInfo.game,
        connectionInfo.userName,
        _ArchipelagoGlobal.generateUUID(),
        _ArchipelagoGlobal.supportedVersion,
        connectionInfo.itemFlags,
        connectionInfo.tags,
        connectionInfo.receiveSlotData,
      ),
    );

    // Get either the second or third message, depending on _getDataPackage
    final server.ServerMessage connectionStatus =
        await stream.skip(++messageSkip).first;

    if (connectionStatus is server.Connected) {
      // Connected
    } else if (connectionStatus is server.ConnectionRefused) {
      throw ArchipelagoConnectionRefused(
        connectionStatus.errors?.map((e) => e.toString()).toList(),
      );
    } else {
      throw HandshakeException(
        HandshakeExceptionType.didNotRecieveConnectionResponse,
      );
    }

    _ArchipelagoRoomInfo currentRoomInfo = _ArchipelagoRoomInfo(
      connectionStatus.players,
      connectionStatus.checkedLocations,
    );

    _ArchipelagoClientInfo currentClientInfo = _ArchipelagoClientInfo(
      connectionInfo.itemFlags.otherWorlds,
      connectionInfo.itemFlags.ownWorld,
      connectionInfo.itemFlags.startingInventory,
      connectionInfo.tags,
    );

    return ArchipelagoClient(currentClientInfo, currentRoomInfo, roomInfo);
  }

  void send(client.ClientMessage message) {
    _sink.add(message.toJson());
  }
}

final class HandshakeException implements Exception {
  final HandshakeExceptionType type;
  final String? description;
  HandshakeException(this.type, [this.description]);
}

final class ArchipelagoConnectionRefused implements Exception {
  final List<String>? errors;
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
