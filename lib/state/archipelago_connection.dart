import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:archipelago/archipelago.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class ArchipelagoConnection with ChangeNotifier {
  final ArchipelagoClient client;
  final StreamController<ArchipelagoEvent> _streamController =
      StreamController.broadcast();
  final MessageList displayMessages = MessageList([]);
  Stream<ArchipelagoEvent> get stream => _streamController.stream;
  bool _connected = true;
  bool get connected => _connected;

  final ConnectionParamaters connectionParamaters;

  ArchipelagoConnection._({
    required this.connectionParamaters,
    required this.client,
  }) {
    // TODO: This doesn't work yet
    _streamController.addStream(client.stream).whenComplete(() {
      _connected = false;
      log('Connection to Archipelago server closed.', level: Level.INFO.value);
      notifyListeners();
    });
    stream.listen((event) {
      if (event is RoomUpdate) {
        client.applyRoomUpdate(event);
      }
    });
  }

  static Future<ArchipelagoConnection> connect({
    required String host,
    required int port,
    required String name,
    String? password,
    required String uuid,
  }) async {
    log(
      'Connecting to Archipelago server on $host:$port, username: $name, password $password',
      level: Level.INFO.value,
    );
    final connector = ArchipelagoProtocolConnector(host, port);
    try {
      final client = await ArchipelagoClient.connectWithConnector(
        connector: connector,
        name: name,
        uuid: uuid,
        password: password,
        tags: ['TextOnly', 'Buttplug'],
        receiveOtherWorlds: false,
        receiveOwnWorld: false,
        receiveStartingInventory: false,
      );
      log('Connected to Archipelago server.', level: Level.INFO.value);
      final params = ConnectionParamaters(
        host: host,
        port: port,
        name: name,
        uuid: uuid,
      );
      return ArchipelagoConnection._(
        connectionParamaters: params,
        client: client,
      );
    } catch (e) {
      log(
        'Connection to Archipelago server failed.',
        error: e,
        level: Level.SEVERE.value,
      );
      rethrow;
    }
  }

  void updateRoomInformation(RoomUpdate update) {
    client.applyRoomUpdate(update);
  }

  void say(String message) {
    client.say(message);
  }
}

class MessageList extends ChangeNotifier {
  final List<DisplayMessage> _messages;
  List<DisplayMessage> get messages => UnmodifiableListView(_messages);

  MessageList(this._messages);

  void addMessage(DisplayMessage message) {
    _messages.add(message);
    notifyListeners();
  }
}

class ConnectionParamaters {
  final String host;
  final int port;
  final String name;
  final String? password;
  final String uuid;

  ConnectionParamaters({
    required this.host,
    required this.port,
    required this.name,
    this.password,
    required this.uuid,
  });
}
