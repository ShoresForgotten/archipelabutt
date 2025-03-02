import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'dart:math' show min, max;

import 'package:archipelabutt/archipelago_text_client.dart';
import 'package:buttplug/buttplug.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'archipelago/archipelago.dart';

class ArchipelabuttState extends ChangeNotifier {
  final ArchipelagoConnection apConn;
  final ButtplugConnection bpConn = ButtplugConnection();
  final MessageList apDisplayMessages = MessageList([]);
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
          // TODO: not this
          notifyListeners();
        default:
      }
      bpDevices.handleEvent(event);
    });
  }

  Future<void> apConnect() async {
    await apConn.connect();
    notifyListeners();
  }

  Future<void> bpConnect() async {
    await bpConn.connect();
    _bpStreamSub = bpConn.client?.eventStream.listen((event) {
      switch (event) {
        case DeviceAddedEvent():
          bpDevices.addDevice(event.device);
        case DeviceRemovedEvent():
          bpDevices.removeDevice(event.device);
      }
      notifyListeners();
    });
    bpConn.client?.devices.forEach((key, value) => bpDevices.addDevice(value));
    notifyListeners();
  }

  void updateBpDevices() {
    bpConn.client?.devices.forEach((key, value) {
      if (!bpDevices.devices.keys.contains(key)) {
        bpDevices.addDevice(value);
      }
    });
    bpDevices.devices.removeWhere((k, _) {
      return bpConn.client == null || !(bpConn.client!.devices.containsKey(k));
    });
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
    try {
      await client.connect(connector);
      log('Connected to Buttplug server', level: Level.INFO.value);
      this.client = client;
    } on SocketException catch (e) {
      log('Connection failed.', error: e, level: Level.INFO.value);
      rethrow;
    }
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
  String password;

  ArchipelagoConnection(
    this.uuid, [
    this.host = '',
    this.port = 38281,
    this.name = '',
    this.password = '',
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
      password: password,
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

interface class ArchipelabuttDevice {
  ArchipelabuttDeviceController controller;
  ArchipelabuttCommandStrategy strategy;

  void handleEvent(ArchipelagoEvent event) {
    final command = strategy.handleEvent(event);
    if (command != null) {
      controller.sendCommand(command);
    }
  }

  ArchipelabuttDevice(this.controller, this.strategy);
}

class ArchipelabuttDeviceController {
  static Map<
    String,
    ArchipelabuttDeviceController Function(ButtplugClientDevice)
  >
  options = {
    ArchipelabuttDeviceController.controllerName:
        ArchipelabuttDeviceController.new,
    DemoController.controllerName: DemoController.new,
  };

  static final String controllerName = 'Default';
  String get cName => controllerName;
  final ButtplugClientDevice device;
  ArchipelabuttDeviceController(this.device);

  List<ArchipelabuttUserSetting> get settings => [];

  void sendCommand(ArchipelabuttDeviceCommand command) {
    try {
      switch (command) {
        case ArchipelabuttVibrateCommand():
          device.vibrate(
            ButtplugDeviceCommand.setAll(VibrateComponent(command.speed)),
          );
          break;
        case ArchipelabuttScalarCommand():
          device.scalar(
            ButtplugDeviceCommand.setAll(
              ScalarComponent(command.scalar, command.actuatorType),
            ),
          );
          break;
        case ArchipelabuttRotateCommand():
          device.rotate(
            ButtplugDeviceCommand.setAll(
              RotateComponent(command.speed, command.clockwise),
            ),
          );
        case ArchipelabuttLinearCommand():
          device.linear(
            ButtplugDeviceCommand.setAll(
              LinearComponent(command.position, command.duration),
            ),
          );
      }
    } catch (e) {
      log(e.toString(), level: Level.WARNING.value);
    }
  }
}

/// HACK CLASS PURELY FOR DEMO PURPOSES
class DemoController implements ArchipelabuttDeviceController {
  static final String controllerName = 'Demo';
  @override
  String get cName => controllerName;

  final ButtplugClientDevice device;

  DemoController(this.device);

  @override
  void sendCommand(ArchipelabuttDeviceCommand command) {
    try {
      switch (command) {
        case ArchipelabuttVibrateCommand():
          device.scalar(
            ButtplugDeviceCommand.setAll(
              ScalarComponent(command.speed, ActuatorType.Oscillate),
            ),
          );
          break;
        case ArchipelabuttScalarCommand():
          device.scalar(
            ButtplugDeviceCommand.setAll(
              ScalarComponent(command.scalar, command.actuatorType),
            ),
          );
          break;
        case ArchipelabuttRotateCommand():
          device.rotate(
            ButtplugDeviceCommand.setAll(
              RotateComponent(command.speed, command.clockwise),
            ),
          );
        case ArchipelabuttLinearCommand():
          device.linear(
            ButtplugDeviceCommand.setAll(
              LinearComponent(command.position, command.duration),
            ),
          );
      }
    } catch (e) {
      log(e.toString(), level: Level.WARNING.value);
    }
  }

  // HACK TEST
  void bingusTest(double pos, int duration) {
    device.scalar(
      ButtplugDeviceCommand.setAll(
        ScalarComponent(pos, ActuatorType.Oscillate),
      ),
    );
  }

  void bingusTwo(double pos1, double pos2, int duration) {
    device.linear(
      ButtplugDeviceCommand.setVec([
        LinearComponent(pos1, duration),
        LinearComponent(pos2, duration),
      ]),
    );
  }

  @override
  List<ArchipelabuttUserSetting> get settings => [];
}

sealed class ArchipelabuttDeviceCommand {}

class ArchipelabuttVibrateCommand extends ArchipelabuttDeviceCommand {
  final double speed;
  ArchipelabuttVibrateCommand(this.speed);
}

class ArchipelabuttScalarCommand extends ArchipelabuttDeviceCommand {
  final double scalar;
  final ActuatorType actuatorType;

  ArchipelabuttScalarCommand(this.scalar, this.actuatorType);
}

class ArchipelabuttRotateCommand extends ArchipelabuttDeviceCommand {
  final double speed;
  final bool clockwise;

  ArchipelabuttRotateCommand(this.speed, this.clockwise);
}

class ArchipelabuttLinearCommand extends ArchipelabuttDeviceCommand {
  final int duration;
  final double position;

  ArchipelabuttLinearCommand(this.duration, this.position);
}

abstract interface class ArchipelabuttCommandStrategy {
  ArchipelabuttDeviceCommand? handleEvent(ArchipelagoEvent event);
  abstract String strategyName;
  List<ArchipelabuttUserSetting> get settings;

  static Map<String, ArchipelabuttCommandStrategy Function()> options = {
    'Empty': EmptyStrategy.new,
    'Points': ArchipelabuttPointsStrategy.new,
  };
}

class EmptyStrategy implements ArchipelabuttCommandStrategy {
  EmptyStrategy();
  @override
  String strategyName = 'Empty';

  @override
  ArchipelabuttDeviceCommand? handleEvent(_) {
    return null;
  }

  @override
  List<ArchipelabuttUserSetting> get settings => [];
}

class ArchipelabuttPointsStrategy implements ArchipelabuttCommandStrategy {
  final ArchipelabuttPointsSystem _pointsSystem;
  final ArchipelabuttDoubleSetting level;
  @override
  String strategyName = 'Points';

  ArchipelabuttPointsStrategy([
    ArchipelabuttPointsSystem? pointsSystem,
    double startValue = 0,
    double? minValue,
    double? maxValue,
  ]) : level = ArchipelabuttDoubleSetting(
         startValue,
         'Current Level',
         minValue,
         maxValue,
       ),
       _pointsSystem = pointsSystem ?? CheckPointsSystem();

  @override
  ArchipelabuttDeviceCommand handleEvent(ArchipelagoEvent event) {
    level.value = _pointsSystem.pointsChange(event, level.value).clamp(0, 1);
    return ArchipelabuttVibrateCommand(level.value);
  }

  @override
  List<ArchipelabuttUserSetting> get settings {
    final List<ArchipelabuttUserSetting<dynamic>> ret = [level];
    for (var e in _pointsSystem.settings) {
      ret.add(e);
    }
    return ret;
  }
}

abstract interface class ArchipelabuttPointsSystem {
  List<ArchipelabuttUserSetting> get settings;
  double pointsChange(ArchipelagoEvent event, [double currentLevel]);
}

class CheckPointsSystem implements ArchipelabuttPointsSystem {
  ArchipelabuttDoubleSetting basePointsValue;
  ArchipelabuttDoubleSetting logicalAdvancementModifier;
  ArchipelabuttDoubleSetting usefulModifier;
  ArchipelabuttDoubleSetting trapModifier;
  ArchipelabuttUserSetting<Player> trackedPlayer;

  CheckPointsSystem([
    double? basePointsValue,
    double? logicalAdvancementModifier,
    double? usefulModifier,
    double? trapModifier,
    Player? trackedPlayer,
  ]) : basePointsValue = ArchipelabuttDoubleSetting(
         basePointsValue ?? 0,
         'Base value',
       ),
       logicalAdvancementModifier = ArchipelabuttDoubleSetting(
         logicalAdvancementModifier ?? 0,
         'Logical advancement modifier',
       ),
       usefulModifier = ArchipelabuttDoubleSetting(
         usefulModifier ?? 0,
         'Useful modifier',
       ),
       trapModifier = ArchipelabuttDoubleSetting(
         trapModifier ?? 0,
         'Trap modifier',
       ),
       trackedPlayer = ArchipelabuttUserSetting<Player>(
         Player('Placeholder'),
         'Tracked Player',
       );

  @override
  double pointsChange(ArchipelagoEvent event, [double currentLevel = 0]) {
    if (event is DisplayMessage &&
        event is ItemSend &&
        event.item.player.name == trackedPlayer.value.name) {
      var sum = currentLevel + basePointsValue.value;
      if (event.item.item.logicalAdvancement)
        sum += logicalAdvancementModifier.value;
      if (event.item.item.useful) sum += usefulModifier.value;
      if (event.item.item.trap) sum += trapModifier.value;
      return sum;
    } else {
      return currentLevel;
    }
  }

  @override
  List<ArchipelabuttUserSetting> get settings => [
    basePointsValue,
    logicalAdvancementModifier,
    usefulModifier,
    trapModifier,
    trackedPlayer,
  ];
}

interface class ArchipelabuttUserSetting<T> {
  final String label;
  T _value;
  T get value => _value;
  set value(T val) => _value = val;

  ArchipelabuttUserSetting(this._value, this.label);
}

class ArchipelabuttDoubleSetting implements ArchipelabuttUserSetting<double> {
  @override
  final String label;
  @override
  double _value;
  final double? _maxValue;
  final double? _minValue;
  @override
  double get value => _value;
  @override
  set value(double val) {
    if (_minValue != null && _maxValue != null) {
      _value = val.clamp(_minValue, _maxValue);
    } else if (_minValue != null) {
      _value = max(val, _minValue);
    } else if (_maxValue != null) {
      _value = min(val, _maxValue);
    } else {
      _value = val;
    }
  }

  ArchipelabuttDoubleSetting(
    this._value,
    this.label, [
    this._minValue,
    this._maxValue,
  ]);
}

class ArchipelabuttListSetting<T> implements ArchipelabuttUserSetting<T> {
  @override
  final String label;
  final List<T> _possibleValues;
  List<T> get possibleValues => UnmodifiableListView(_possibleValues);
  @override
  T _value;
  @override
  T get value => _value;
  set value(T val) {
    if (!_possibleValues.contains(val) || val != null) {
      throw Error();
    } else {
      _value = val;
    }
  }

  List<T> get settings => UnmodifiableListView(_possibleValues);

  ArchipelabuttListSetting(this._possibleValues, this._value, this.label);
}

class ButtplugDevices {
  Map<int, ArchipelabuttDevice> _devices = {};
  Map<int, ArchipelabuttDevice> get devices => _devices;

  void addDevice(ButtplugClientDevice device) {
    _devices[device.index] = ArchipelabuttDevice(
      ArchipelabuttDeviceController(device),
      EmptyStrategy(),
    );
  }

  void removeDevice(ButtplugClientDevice device) {
    _devices.remove(device.index);
  }

  void handleEvent(ArchipelagoEvent event) {
    _devices.forEach((key, value) {
      value.handleEvent(event);
    });
  }
}
