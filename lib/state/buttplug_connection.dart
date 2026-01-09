import 'dart:async';
import 'dart:developer';

import 'package:buttplug/buttplug.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class ButtplugConnection with ChangeNotifier {
  final ButtplugClient client;
  final String host;
  final int port;
  final StreamController<ButtplugClientEvent> _streamController =
      StreamController.broadcast();
  Stream<ButtplugClientEvent> get stream => _streamController.stream;
  bool _connected = true;
  bool get connected => _connected;

  ButtplugConnection._(this.host, this.port, this.client) {
    // This doesn't actually do anything, since buttplug doesn't actually end the stream.
    // TODO: fix this?
    _streamController.addStream(client.eventStream).whenComplete(() {
      _connected = false;
      log('Connection to Buttplug server closed.', level: Level.INFO.value);
      notifyListeners();
    });
  }

  static Future<ButtplugConnection> connect({
    required String host,
    required int port,
  }) async {
    final uri = Uri(host: host, port: port, scheme: 'ws');
    final ButtplugWebsocketClientConnector connector =
        ButtplugWebsocketClientConnector(uri.toString());
    // TODO: Make this do something
    // ButtplugWebSocketClientConnector doesn't actually do anything with the address, it's hardcoded to connect to ws://127.0.0.1:1245/
    final ButtplugClient client = ButtplugClient('Archipelabutt');
    log('Connecting to Buttplug server on $uri', level: Level.INFO.value);
    try {
      await client.connect(connector);
      log('Connected to Buttplug server', level: Level.INFO.value);
      return ButtplugConnection._(host, port, client);
    } catch (e) {
      log('Connection failed.', error: e, level: Level.SEVERE.value);
      rethrow; //TODO: Do we rethrow here?
    }
  }
}
