import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:buttplug/buttplug.dart';
import 'package:logging/logging.dart';

class ButtplugConnection {
  ButtplugClient? client;
  String host = 'localhost';
  int port = 12345;
  final StreamController<ButtplugClientEvent> _streamController =
      StreamController.broadcast();
  Stream<ButtplugClientEvent> get stream => _streamController.stream;

  bool get connected => client?.connected() ?? false;

  ButtplugConnection();

  Future<void> connect() async {
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
    } on SocketException catch (e) {
      //TODO: Update buttplug_dart dependency, when it updates, so this exception can actually be caught
      log('Connection failed.', error: e, level: Level.INFO.value);
      rethrow;
    }
  }
}
