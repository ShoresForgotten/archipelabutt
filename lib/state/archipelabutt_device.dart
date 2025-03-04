import 'dart:collection';
import 'dart:developer';
import 'dart:math' show max, min;

import 'package:archipelabutt/archipelago/archipelago.dart';
import 'package:buttplug/buttplug.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

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
                (x) => ArchipelabuttDeviceFeature<ScalarComponent>(
                  x,
                  EmptyScalarStrategy(),
                ),
              )
              .toList();
}

class ArchipelabuttDeviceFeature<T> {
  final ClientGenericDeviceMessageAttributes _attributes;
  List<ArchipelabuttUserSetting<dynamic>> get settings => strategy.settings;
  String get description => _attributes.featureDescriptor;
  ActuatorType get actuatorType => _attributes.actuatorType;
  int get stepCount => _attributes.stepCount;
  ArchipelabuttStrategy<T> strategy;

  T handleEvent(ArchipelagoEvent event) =>
      strategy.handleEvent(event, actuatorType);

  ArchipelabuttDeviceFeature(this._attributes, this.strategy);
}

abstract class ArchipelabuttStrategy<T> {
  List<ArchipelabuttUserSetting<dynamic>> get settings;

  T handleEvent(ArchipelagoEvent event, ActuatorType actuator);
}

typedef ArchipelabuttScalarStrategy = ArchipelabuttStrategy<ScalarComponent>;

class EmptyScalarStrategy extends ArchipelabuttScalarStrategy {
  @override
  final settings = [];
  @override
  ScalarComponent handleEvent(_, actuator) => ScalarComponent(0, actuator);
}

class PointsSustainScalarStrategy implements ArchipelabuttScalarStrategy {
  @override
  List<ArchipelabuttUserSetting<dynamic>> get settings => pointsSystem.settings;
  ArchipelabuttPointsSystem pointsSystem = CheckPointsSystem();
  double currentLevel = 0;
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
