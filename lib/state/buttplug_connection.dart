import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:buttplug/buttplug.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class ButtplugConnection with ChangeNotifier {
  ButtplugClient? client;
  String host = 'localhost';
  int port = 12345;
  final StreamController<ButtplugClientEvent> _streamController =
      StreamController.broadcast();
  Stream<ButtplugClientEvent> get stream => _streamController.stream;
  bool _connected = false;

  bool get connected => _connected;

  ButtplugConnection();

  Future<void> connect() async {
    if (connected) {
      Error();
    }
    final uri = Uri(host: host, port: port, scheme: 'ws');
    // TODO: Make this do something
    // ButtplugWebSocketClientConnector doesn't actually do anything with the address, it's hardcoded to connect to ws://127.0.0.1:1245/
    final ButtplugWebsocketClientConnector connector =
        ButtplugWebsocketClientConnector(uri.toString());
    final ButtplugClient client = ButtplugClient('Archipelabutt');
    log('Connecting to Buttplug server on $uri', level: Level.INFO.value);
    try {
      await client.connect(connector);
      log('Connected to Buttplug server', level: Level.INFO.value);
      this.client = client;
      _connected = true;
      notifyListeners();
      _streamController.addStream(client.eventStream).whenComplete(() {
        log('Disconnected from Buttplug server', level: Level.INFO.value);
        _connected = false;
        notifyListeners();
      });
    } catch (e) {
      log('Connection failed.', error: e, level: Level.SEVERE.value);
      rethrow;
    }
  }
}
