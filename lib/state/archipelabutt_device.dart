import 'dart:collection';

import 'package:archipelago/archipelago.dart';
import 'package:buttplug/buttplug.dart';
import 'package:flutter/material.dart';

class ArchipelabuttDeviceIndex with ChangeNotifier {
  final Map<int, ArchipelabuttDevice> _devices = {};
  UnmodifiableMapView<int, ArchipelabuttDevice> get devices =>
      UnmodifiableMapView(_devices);

  void addDevice(ButtplugClientDevice device) {
    _devices[device.index] = ArchipelabuttDevice(device);
    notifyListeners();
  }

  void removeDevice(ButtplugClientDevice device) {
    _devices.remove(device.index);
    notifyListeners();
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
  final List<ArchipelabuttDeviceFeature<ScalarComponent>>? _scalarFeatures;
  UnmodifiableListView<ArchipelabuttDeviceFeature<ScalarComponent>>?
  get scalarFeatures =>
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

  void stop() {
    //TODO
  }

  ArchipelabuttDevice(this._device)
    : _scalarFeatures =
          _device.messageAttributes.scalarCmd
              ?.map(
                (x) => ArchipelabuttDeviceFeature<ScalarComponent>(x, [
                  EmptyScalarStrategy(),
                  PointsSustainScalarStrategy(),
                ]),
              )
              .toList();
}

class ArchipelabuttDeviceFeature<T> {
  final ClientGenericDeviceMessageAttributes _attributes;
  List<ArchipelabuttUserSetting<dynamic>> get settings =>
      activeStrategy.settings;
  String get description =>
      _attributes.featureDescriptor == ''
          ? _actuatorTypeToString(actuatorType)
          : _attributes.featureDescriptor;
  ActuatorType get actuatorType => _attributes.actuatorType;
  int get stepCount => _attributes.stepCount;
  ArchipelabuttStrategy<T> activeStrategy;
  List<ArchipelabuttStrategy<T>> availableStrategies;

  T handleEvent(ArchipelagoEvent event) =>
      activeStrategy.handleEvent(event, actuatorType);

  ArchipelabuttDeviceFeature(this._attributes, this.availableStrategies)
    : activeStrategy = availableStrategies.first;

  String _actuatorTypeToString(ActuatorType type) {
    switch (type) {
      case ActuatorType.Vibrate:
        return 'Vibrate';
      case ActuatorType.Rotate:
        return 'Rotate';
      case ActuatorType.Oscillate:
        return 'Oscillate';
      case ActuatorType.Constrict:
        return 'Constrict';
      case ActuatorType.Inflate:
        return 'Inflate';
      case ActuatorType.Position:
        return 'Position';
    }
  }
}

abstract class ArchipelabuttStrategy<T> {
  final String name;

  ArchipelabuttStrategy({required this.name});
  List<ArchipelabuttUserSetting<dynamic>> get settings;

  T handleEvent(ArchipelagoEvent event, ActuatorType actuator);
}

typedef ArchipelabuttScalarStrategy = ArchipelabuttStrategy<ScalarComponent>;

class EmptyScalarStrategy extends ArchipelabuttScalarStrategy {
  @override
  final settings = [];

  EmptyScalarStrategy() : super(name: 'Empty');
  @override
  ScalarComponent handleEvent(_, actuator) => ScalarComponent(0, actuator);
}

class PointsSustainScalarStrategy extends ArchipelabuttScalarStrategy {
  @override
  List<ArchipelabuttUserSetting<dynamic>> get settings => pointsSystem.settings;
  ArchipelabuttPointsSystem pointsSystem = CheckPointsSystem();
  double currentLevel = 0;

  PointsSustainScalarStrategy() : super(name: 'Points Sustain');
  @override
  ScalarComponent handleEvent(ArchipelagoEvent event, ActuatorType actuator) {
    currentLevel = pointsSystem.pointsChange(event, currentLevel).clamp(0, 1);
    return ScalarComponent(currentLevel, actuator);
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

class ArchipelabuttUserSetting<T> {
  final String label;
  T value;

  ArchipelabuttUserSetting(this.value, this.label);
}

class ArchipelabuttDoubleSetting extends ArchipelabuttUserSetting<double> {
  final double? maxValue;
  final double? minValue;

  ArchipelabuttDoubleSetting(
    super.initialValue,
    super.label, [
    this.minValue,
    this.maxValue,
  ]);
}

class ArchipelabuttListSetting<T> extends ArchipelabuttUserSetting<T> {
  final List<T> _possibleValues;
  List<T> get possibleValues => UnmodifiableListView(_possibleValues);

  List<T> get settings => UnmodifiableListView(_possibleValues);

  ArchipelabuttListSetting(super.value, super.label, this._possibleValues);
}
