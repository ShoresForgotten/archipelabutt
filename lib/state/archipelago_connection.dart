import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:archipelago/archipelago.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class ArchipelagoConnection with ChangeNotifier {
  ArchipelagoClient? client;
  final StreamController<ArchipelagoEvent> _streamController =
      StreamController.broadcast();
  final MessageList displayMessages = MessageList([]);
  Stream<ArchipelagoEvent> get stream => _streamController.stream;
  bool _connected = false;
  bool get connected => _connected;

  String host;
  int port;
  String name;
  String uuid;
  String password;

  ArchipelagoConnection(
    this.uuid, [
    this.host = '',
    this.port = 38281,
    this.name = '',
    this.password = '',
  ]);

  Future<void> connect() async {
    if (connected) {
      Error();
    }
    log(
      'Connecting to Archipelago server on $host:$port, username: $name.',
      level: Level.INFO.value,
    );
    final connector = ArchipelagoConnector(host, port);
    final client = await ArchipelagoClient.connect(
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
    this.client = client;
    client.stream.listen(
      (event) {
        if (event is DisplayMessage) {
          displayMessages.addMessage(event);
        }
        _streamController.add(event);
      },
      onDone: () {
        _connected = false;
        notifyListeners();
        log(
          'Connection to Archipelago server closed.',
          level: Level.INFO.value,
        );
      },
    );
    _connected = true;
  }

  void updateRoomInformation(RoomUpdate update) {
    client?.applyRoomUpdate(update);
    notifyListeners();
  }

  void say(String message) {
    client?.say(message);
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
