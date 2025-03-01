import 'dart:async';
import 'dart:developer';

import 'package:buttplug/buttplug.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'archipelago/archipelago.dart';

class ArchipelabuttState extends ChangeNotifier {
  final ArchipelagoConnection apConn;
  final ButtplugConnection bpConn = ButtplugConnection();
  final ArchipelagoDisplayMessageLog apDisplayMessages =
      ArchipelagoDisplayMessageLog();
  StreamSubscription<ArchipelagoEvent>? _apStreamSub;
  Stream<ArchipelagoEvent> get apStream => apConn.stream;
  StreamSubscription<ButtplugClientEvent>? _bpStreamSub;
  final ButtplugDevices bpDevices = ButtplugDevices();

  ArchipelabuttState(String uuid) : apConn = ArchipelagoConnection(uuid) {
    _apStreamSub = apConn.stream.listen((event) {
      switch (event) {
        case RoomUpdate():
          apConn.client?.applyRoomUpdate(event);
          notifyListeners();
        case DisplayMessage():
          apDisplayMessages.addMessage(event);
        default:
      }
    });
  }

  Future<void> apConnect() async {
    await apConn.connect();
    notifyListeners();
  }

  Future<void> bpConnect() async {
    await bpConn.connect();
    _bpStreamSub = bpConn.client!.eventStream.listen((event) {
      switch (event) {
        case DeviceAddedEvent():
          bpDevices.addDevice(event);
        case DeviceRemovedEvent():
          bpDevices.removeDevice(event);
      }
    });
    notifyListeners();
  }
}

class ButtplugConnection {
  ButtplugClient? client;
  String host = 'localhost';
  int port = 12345;

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
  }
}

class ArchipelagoConnection {
  ArchipelagoClient? client;
  final StreamController<ArchipelagoEvent> _streamController =
      StreamController.broadcast();
  Stream<ArchipelagoEvent> get stream => _streamController.stream;

  String host;
  int port;
  String name;
  String uuid;

  ArchipelagoConnection(
    this.uuid, [
    this.host = '',
    this.port = 0,
    this.name = '',
  ]);

  Future<void> connect() async {
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
    // TODO: check for when this finishes
    _streamController.addStream(client.stream);
  }
}

abstract interface class ArchipelabuttDeviceController {
  ButtplugClientDevice get device;
}

class EmptyController implements ArchipelabuttDeviceController {
  final ButtplugClientDevice device;
  EmptyController(this.device);
}

abstract interface class ArchipelabuttDeviceSetting {}

class ArchipelabuttPointsController implements ArchipelabuttDeviceController {
  late final StreamSubscription<ArchipelagoEvent> _sub;
  final ArchipelabuttScalarDevice _device;
  ButtplugClientDevice get device => _device.device;
  final ArchipelabuttPointsSystem _pointsSystem;
  double currentLevel;

  ArchipelabuttPointsController(
    Stream<ArchipelagoEvent> stream,
    this._device,
    this._pointsSystem, [
    this.currentLevel = 0,
  ]) {
    _sub = stream.listen((event) {
      final level = _pointsSystem
          .pointsChange(event, currentLevel)
          .clamp(0.0, 1.0);
      if (level != currentLevel) {
        currentLevel = level;
        _device.setLevel(level);
      }
    });
  }

  void dispose() {
    _sub.cancel();
  }
}

abstract interface class ArchipelabuttPointsSystem {
  double pointsChange(ArchipelagoEvent event, [double currentLevel]);
}

class CheckPointsSystem implements ArchipelabuttPointsSystem {
  double basePointsValue;
  double logicalAdvancementModifier;
  double usefulModifier;
  double trapModifier;
  Player trackedPlayer;

  CheckPointsSystem(
    this.basePointsValue,
    this.logicalAdvancementModifier,
    this.usefulModifier,
    this.trapModifier,
    this.trackedPlayer,
  );

  @override
  double pointsChange(ArchipelagoEvent event, [double currentLevel = 0]) {
    if (event is DisplayMessage &&
        event is ItemSend &&
        event.item.player.id == trackedPlayer.id) {
      var sum = currentLevel + basePointsValue;
      if (event.item.item.logicalAdvancement) sum += logicalAdvancementModifier;
      if (event.item.item.useful) sum += usefulModifier;
      if (event.item.item.trap) sum += trapModifier;
      return sum;
    } else {
      return currentLevel;
    }
  }
}

abstract interface class ArchipelabuttScalarDevice {
  ButtplugClientDevice get device;
  setLevel(double scalar);
  void stop();
}

class LinearToScalarWrapper implements ArchipelabuttScalarDevice {
  int _currentPeriod;
  final int _minPeriod;
  final int _maxPeriod;
  final ButtplugClientDevice _device;
  ButtplugClientDevice get device => _device;

  LinearToScalarWrapper(
    this._minPeriod,
    this._maxPeriod,
    this._device,
    this._currentPeriod,
  );

  @override
  setLevel(double period) {
    _currentPeriod = ((_maxPeriod - _minPeriod) * period + _minPeriod).floor();
    _device.linear(
      ButtplugDeviceCommand.setVec([
        LinearComponent(0.0, _currentPeriod),
        LinearComponent(1.0, _currentPeriod),
      ]),
    );
  }

  @override
  void stop() {
    _device.linear(
      ButtplugDeviceCommand.setAll(LinearComponent(0.0, _currentPeriod)),
    );
  }
}

class ArchipelabuttVibrate implements ArchipelabuttScalarDevice {
  double _currentLevel;
  final ButtplugClientDevice _device;
  ArchipelabuttVibrate(this._device, this._currentLevel);

  @override
  setLevel(double speed) {
    _currentLevel = speed;
    _device.vibrate(ButtplugDeviceCommand.setAll(VibrateComponent(speed)));
  }

  @override
  void stop() {
    _device.vibrate(ButtplugDeviceCommand.setAll(VibrateComponent(0)));
  }
}

class ArchipelagoDisplayMessageLog extends ChangeNotifier {
  final List<DisplayMessage> messages = [];

  void addMessage(DisplayMessage message) {
    messages.add(message);
    notifyListeners();
  }
}

class ArchipelabuttIntensitySettings extends ChangeNotifier {
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

class ButtplugDevices extends ChangeNotifier {
  Map<int, ButtplugClientDevice> devices = {};
  Map<int, ArchipelabuttDeviceController> deviceControllers = {};

  void addDevice(DeviceAddedEvent event) {
    devices[event.device.index] = event.device;
    notifyListeners();
  }

  void removeDevice(DeviceRemovedEvent event) {
    devices.remove(event.device.index);
    deviceControllers.remove(event.device.index);
    notifyListeners();
  }

  void addController(ArchipelabuttDeviceController controller, int index) {
    if (devices.containsKey(index)) {
      deviceControllers[index] = controller;
    }
  }

  void removeController(int index) {
    deviceControllers.remove(index);
  }
}
