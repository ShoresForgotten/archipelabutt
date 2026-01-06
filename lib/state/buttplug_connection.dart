import 'dart:async';
import 'dart:developer';

import 'package:buttplug/buttplug.dart';
import 'package:logging/logging.dart';

class ButtplugConnection {
  final ButtplugClient client;
  final String host;
  final int port;
  final StreamController<ButtplugClientEvent> _streamController;
  Stream<ButtplugClientEvent> get stream => _streamController.stream;

  ButtplugConnection._(
    this.host,
    this.port,
    this._streamController,
    this.client,
  );

  static Future<ButtplugConnection?> connect(String host, int port) async {
    final uri = Uri(host: host, port: port, scheme: 'ws');
    final ButtplugWebsocketClientConnector connector =
        ButtplugWebsocketClientConnector(uri.toString());
    final StreamController<ButtplugClientEvent> streamController =
        StreamController.broadcast();
    // TODO: Make this do something
    // ButtplugWebSocketClientConnector doesn't actually do anything with the address, it's hardcoded to connect to ws://127.0.0.1:1245/
    final ButtplugClient client = ButtplugClient('Archipelabutt');
    log('Connecting to Buttplug server on $uri', level: Level.INFO.value);
    try {
      await client.connect(connector);
      log('Connected to Buttplug server', level: Level.INFO.value);
      streamController.addStream(client.eventStream).whenComplete(() {
        log('Disconnected from Buttplug server', level: Level.INFO.value);
      });
      return ButtplugConnection._(host, port, streamController, client);
    } catch (e) {
      log('Connection failed.', error: e, level: Level.SEVERE.value);
      rethrow;
    }
  }
}
