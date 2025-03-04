import 'dart:collection';
import 'dart:developer';
import 'dart:math' show max, min;

import 'package:archipelabutt/archipelago/archipelago.dart';
import 'package:buttplug/buttplug.dart';
import 'package:logging/logging.dart';

class ArchipelabuttDeviceIndex {
  final Map<int, ArchipelabuttDevice> _devices = {};
  UnmodifiableMapView<int, ArchipelabuttDevice> get devices =>
      UnmodifiableMapView(_devices);

  void addDevice(ButtplugClientDevice device) {
    _devices[device.index] = ArchipelabuttDevice(device);
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

class ArchipelabuttDevice {
  final ButtplugClientDevice _device;
  String get name => _device.name;
  final List<ArchipelabuttScalarDeviceFeature>? _scalarFeatures;
  UnmodifiableListView<ArchipelabuttScalarDeviceFeature>? get scalarFeatures =>
      _scalarFeatures == null ? null : UnmodifiableListView(_scalarFeatures);
  void handleEvent(ArchipelagoEvent event) {
    if (_scalarFeatures != null) {
      _device.scalar(
        ScalarCommand.setVec(
          _scalarFeatures.map((x) => x.handleEvent(event)).toList(),
        ),
      );
    }
  }

  ArchipelabuttDevice(this._device)
    : _scalarFeatures =
          _device.messageAttributes.scalarCmd
              ?.map((x) => ArchipelabuttScalarDeviceFeature(x))
              .toList();
}

class ArchipelabuttScalarDeviceFeature {
  final ClientGenericDeviceMessageAttributes _attributes;
  String get description => _attributes.featureDescriptor;
  ActuatorType get actuatorType => _attributes.actuatorType;
  int get stepCount => _attributes.stepCount;
  ArchipelabuttScalarStrategy strategy = EmptyScalarStrategy();
  ScalarComponent handleEvent(ArchipelagoEvent event) {
    final scalar = strategy.handleEvent(event);
    return ScalarComponent(scalar, actuatorType);
  }

  ArchipelabuttScalarDeviceFeature(this._attributes);
}

abstract interface class ArchipelabuttScalarStrategy {
  double handleEvent(ArchipelagoEvent event);

  List<ArchipelabuttUserSetting<dynamic>> get settings;
}

class EmptyScalarStrategy implements ArchipelabuttScalarStrategy {
  @override
  final settings = [];
  @override
  double handleEvent(_) => 0;
}

class PointsSustainScalarStrategy implements ArchipelabuttScalarStrategy {
  @override
  List<ArchipelabuttUserSetting<dynamic>> get settings => pointsSystem.settings;
  ArchipelabuttPointsSystem pointsSystem = CheckPointsSystem();
  double currentLevel = 0;
  @override
  double handleEvent(ArchipelagoEvent event) {
    currentLevel = pointsSystem.pointsChange(event, currentLevel).clamp(0, 1);
    return currentLevel;
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
      if (event.item.item.logicalAdvancement) {
        sum += logicalAdvancementModifier.value;
      }
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
  T value;

  ArchipelabuttUserSetting(this.value, this.label);
}

class ArchipelabuttDoubleSetting implements ArchipelabuttUserSetting<double> {
  @override
  final String label;
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
  T _value;
  @override
  T get value => _value;
  @override
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
