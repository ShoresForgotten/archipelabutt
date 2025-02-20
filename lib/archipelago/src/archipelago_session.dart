library;

import 'dart:async';
import 'dart:collection';

import 'archipelago_client_settings.dart';
import 'archipelago_connector.dart';
import 'archipelago_room_info.dart';
import 'protocol_types.dart';
import 'client_to_server.dart';
import 'server_to_client.dart';
import 'consts.dart';

/// Controller class for an Archipelago connection.
/// Encapsulates all the state required for an Archipelago connection.
final class ArchipelagoSession {
  final ArchipelagoConnector _connector;
  final ArchipelagoClientSettings _clientSettings;
  ArchipelagoRoomInfo? _roomInfo;
  Stream<ServerMessage>? _stream;
  Stream<ServerMessage>? get stream => _stream;

  Permission? get releasePermission => _roomInfo?.releasePermission;
  Permission? get collectPermission => _roomInfo?.collectPermission;
  Permission? get remainingPermission => _roomInfo?.remainingPermission;
  List<String>? get roomTags => _roomInfo?.tags;
  int? get hintCost => _roomInfo?.hintCost;

  List<String> get clientTags => _clientSettings.tags;

  bool get receiveOtherWorld => _clientSettings.receiveOtherWorlds;
  bool get receiveOwnWorld => _clientSettings.receiveOwnWorld;
  bool get receiveStartingInventory => _clientSettings.receiveStartingInventory;

  ArchipelagoSession(this._connector, this._clientSettings);

  Future<void> handshake([DataPackageHandler? dataPackageHandler]) async {
    final stream = _connector.stream;

    final queue = _MessageQueue();
    final queueStreamController = stream.listen(
      (event) => queue.addMessage(ServerMessage.fromJson(event)),
    );

    final ServerMessage roomInfo = await queue.getMessage();
    if (roomInfo is! RoomInfo) {
      throw HandshakeException(HandshakeExceptionType.didNotRecieveRoomInfo);
    }

    if (dataPackageHandler != null) {
      final games = dataPackageHandler.selectGames(roomInfo);
      _connector.send(GetDataPackageMessage(games).toJson());
      final ServerMessage dataPackage = await queue.getMessage();
      if (dataPackage is! DataPackage) {
        throw HandshakeException(
          HandshakeExceptionType.didNotRecieveDataPackage,
        );
      }
      dataPackageHandler.handleDataPackage(dataPackage);
    }

    _connector.send(
      ConnectMessage(
        roomInfo.password ? _clientSettings.password : null,
        _clientSettings.game,
        _clientSettings.name,
        _clientSettings.uuid,
        ArchipelagoGlobal.supportedVersion,
        _clientSettings.receiveOtherWorlds,
        _clientSettings.receiveOwnWorld,
        _clientSettings.receiveStartingInventory,
        _clientSettings.tags,
        _clientSettings.receiveSlotData,
      ).toJson(),
    );

    final ServerMessage connected = await queue.getMessage();
    // Stop sending messages to the queue, we've either succeeded or failed by now.
    queueStreamController.cancel();

    if (connected is ConnectionRefused) {
      throw ArchipelagoConnectionRefused(connected.errors);
    } else if (connected is! Connected) {
      throw HandshakeException(
        HandshakeExceptionType.didNotRecieveConnectionResponse,
      );
    }
    _stream = stream.map((event) => ServerMessage.fromJson(event));
  }

  /// Apply a RoomUpdate message.
  void updateRoomInfo(RoomUpdate update) {
    _roomInfo?.updateRoomInfo(
      checkedLocations: update.checkedLocations,
      players: update.players,
      tags: update.tags,
      password: update.password,
      permissions: update.permissions,
      hintCost: update.hintCost,
      locationCheckPoints: update.locationCheckPoints,
      games: update.games,
      datapackageChecksums: update.datapackageChecksums,
      seedName: update.seedName,
      time: update.time,
    );
  }

  void modifyClientSettings({
    List<String>? tags,
    bool? receiveOtherWorlds,
    bool? receiveOwnWorld,
    bool? receiveStartingInventory,
  }) {
    _clientSettings.setItemHandlingFlags(
      receiveOtherWorlds ?? _clientSettings.receiveOtherWorlds,
      receiveOwnWorld ?? _clientSettings.receiveOwnWorld,
      receiveStartingInventory ?? _clientSettings.receiveStartingInventory,
    );
    if (tags != null) _clientSettings.tags = tags;
    send(
      ConnectUpdateMessage(
        _clientSettings.receiveOtherWorlds,
        _clientSettings.receiveOwnWorld,
        _clientSettings.receiveStartingInventory,
        _clientSettings.tags,
      ),
    );
  }

  void checkLocations(List<int> locations) {
    send(LocationChecksMessage(locations));
  }

  void sync() {
    send(SyncMessage());
  }

  void scoutLocations(List<int> locations, bool asHint, bool newHintsOnly) {
    int value = 0;
    if (asHint) {
      if (newHintsOnly) {
        value = 2;
      } else {
        value = 1;
      }
    }
    send(LocationScoutsMessage(locations, value));
  }

  void updateHint(int player, int location, int priority) {
    HintStatus status = HintStatus.unspecified;
    switch (priority) {
      case 0:
        break;
      case 1:
        status = HintStatus.noPriority;
        break;
      case 2:
        status = HintStatus.avoid;
        break;
      case 3:
        status = HintStatus.priority;
        break;
      default:
        Error();
    }
    send(UpdateHintMessage(player, location, status));
  }

  void clientStatus(int value) {
    ClientStatus status = ClientStatus.unknown;
    switch (value) {
      case 5:
        status = ClientStatus.connected;
        break;
      case 10:
        status = ClientStatus.ready;
        break;
      case 20:
        status = ClientStatus.playing;
        break;
      case 30:
        status = ClientStatus.goal;
        break;
      default:
        Error();
    }
    send(StatusUpdateMessage(status));
  }

  void say(String message) {
    send(SayMessage(message));
  }

  void getDataPackage(DataPackageHandler handler, List<String>? games) {
    send(GetDataPackageMessage(games));
  }

  void bounce(
    Map<dynamic, dynamic> data,
    List<String>? games,
    List<int>? slots,
    List<String>? tags,
  ) {
    send(BounceMessage(data: data, games: games, slots: slots, tags: tags));
  }

  void getStorage(List<String> keys) {
    send(GetMessage(keys));
  }

  /// Send a message to the server.
  void send(ClientMessage message) {
    _connector.send(message.toJson());
  }
}

/// A queue to hold messages and return them asynchronously.
/// ONLY USE DURING THE HANDSHAKE.
final class _MessageQueue {
  final Queue<ServerMessage> _queue = Queue();
  Completer<ServerMessage>? _waiting;

  void addMessage(ServerMessage message) {
    if (_waiting == null) {
      _queue.add(message);
    } else {
      _waiting!.complete(message);
      _waiting = null;
    }
  }

  Future<ServerMessage> getMessage() async {
    if (_queue.isEmpty) {
      // This doesn't actually make anything safer
      _waiting ??= Completer();
      return _waiting!.future;
    } else {
      return Future.value(_queue.removeFirst());
    }
  }
}

abstract interface class DataPackageHandler {
  List<String>? selectGames(RoomInfo roomInfo);
  Future<void> handleDataPackage(DataPackage dataPackage);
}

final class HandshakeException implements Exception {
  final HandshakeExceptionType type;
  final String? description;
  HandshakeException(this.type, [this.description]);
}

final class ArchipelagoConnectionRefused implements Exception {
  final List<ConnectionRefusedReason>? errors;
  ArchipelagoConnectionRefused(this.errors);
}

enum HandshakeExceptionType {
  didNotRecieveRoomInfo,
  didNotRecieveDataPackage,
  didNotRecieveConnectionResponse,
}
