import 'dart:async';
import 'dart:developer';

import 'package:buttplug/buttplug.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'archipelago/archipelago.dart';

class ArchipelabuttState extends ChangeNotifier {
  ArchipelagoConnection apConn = ArchipelagoConnection();
  ButtplugConnection bpConn = ButtplugConnection();
  ReceivedMessages messages = ReceivedMessages();
  StreamSubscription<ArchipelagoEvent>? _streamSub;

  Future<void> apConnect(String host, int port, String name, String uuid) async {
    await apConn.connect(host, port, name, uuid);
    this._streamSub = apConn.client!.stream.listen((event) {
      switch (event) {
        case RoomUpdate():
          apConn.client!.applyRoomUpdate(event);
          notifyListeners();
        case ItemsReceived():
          if (event.items.)
        case DisplayMessage():
          messages.add(event);
        default:
      }
    });
  }

}

class ArchipelagoConnection extends ChangeNotifier {
  ArchipelagoClient? client;

  String? host;
  int? port;
  String? name;

  ArchipelagoConnection();

  Future<void> connect(String host, int port, String name, String uuid) async {
    this.host = host;
    this.port = port;
    this.name = name;
    log(
      'Connecting to Archipelago server on $host:$port, username: $name',
      level: Level.INFO.value,
    );
    final client = await ArchipelagoClient.connect(
      host: host,
      port: port,
      name: name,
      uuid: uuid,
      tags: ['TextOnly', 'Buttplug'],
      receiveOtherWorlds: false,
      receiveOwnWorld: false,
      receiveStartingInventory: false,
    );
    log('Connected to Archipelago server', level: Level.INFO.value);
    this.client = client;
    notifyListeners();
  }
}

class ReceivedMessages extends ChangeNotifier {
  final List<DisplayMessage> messages = [];

  void addMessage(DisplayMessage message) {
    messages.add(message);
    notifyListeners();
  }
}

class ButtplugConnection extends ChangeNotifier {
  ButtplugClient? client;
  String host = 'localhost';
  int port = 12345;
  ButtplugClientDevice? activeDevice;

  bool get connected => client?.connected() ?? false;

  ButtplugConnection();

  Future<void> connect() async {
    final uri = Uri(host: host, port: port, scheme: 'ws');
    final ButtplugWebsocketClientConnector connector =
        ButtplugWebsocketClientConnector(uri.toString());
    final ButtplugClient client = ButtplugClient('Archipelabutt');
    log('Connecting to Buttplug server on $uri', level: Level.INFO.value);
    await client.connect(connector);
    log('Connected to Buttplug server', level: Level.INFO.value);
    this.client = client;
    notifyListeners();
  }
}

class ButtplugIntensitySettings extends ChangeNotifier {
  double _minIntensity = 0;
  set minIntensity(double val) {
    if (val > 100) {
      _minIntensity = 100;
    } else if (val < 0) {
      _minIntensity = 0;
    } else {
      _minIntensity = val;
    }
    notifyListeners();
  }

  double get minIntensity => _minIntensity;

  double _maxIntensity = 100;
  set maxIntensity(double val) {
    if (val > 100) {
      _maxIntensity = 100;
    } else if (val < 0) {
      _maxIntensity = 0;
    } else {
      _maxIntensity = val;
    }
    notifyListeners();
  }

  double get maxIntensity => _maxIntensity;

  double _boringCheckValue = 0;
  set boringCheckValue(double val) {
    _boringCheckValue = val;
    notifyListeners();
  }

  double get boringCheckValue => _boringCheckValue;

  double _logicalAdvancementCheckValue = 0;
  set logicalAdvancementCheckValue(double val) {
    _logicalAdvancementCheckValue = val;
    notifyListeners();
  }

  double get logicalAdvancementCheckValue => _logicalAdvancementCheckValue;

  double _usefulCheckValue = 0;
  set usefulCheckValue(double val) {
    _usefulCheckValue = val;
    notifyListeners();
  }

  double get usefulCheckValue => _usefulCheckValue;

  double _trapCheckValue = 0;
  set trapCheckValue(double val) {
    _trapCheckValue = val;
    notifyListeners();
  }

  double get trapCheckValue => _trapCheckValue;

  double _decayRate = 0;
  set decayRate(double val) {
    _decayRate = val;
    notifyListeners();
  }

  double get decayRate => _decayRate;
}
