import 'dart:collection';

import 'package:archipelabutt/feature_strategy/archipelabutt_points_system.dart';
import 'package:archipelabutt/feature_strategy/points_sustain_scalar_strategy.dart';
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
                  PointsSustainScalarStrategy(),
                ]),
              )
              .toList();
}

class ArchipelabuttDeviceFeature<T> {
  final ClientGenericDeviceMessageAttributes _attributes;
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

// TODO: Consider making this work with factory objects
abstract interface class ArchipelabuttStrategy<T> {
  final String name;

  ArchipelabuttStrategy({required this.name});
  List<ArchipelabuttUserSetting<dynamic>> get settings;

  T handleEvent(ArchipelagoEvent event, ActuatorType actuator);
}

typedef ArchipelabuttScalarStrategy = ArchipelabuttStrategy<ScalarComponent>;

sealed class ArchipelabuttUserSetting<T> {
  final String name;
  T value;

  ArchipelabuttUserSetting(this.name, this.value);
}

class DoubleSetting extends ArchipelabuttUserSetting<double> {
  double? maxValue;
  double? minValue;

  DoubleSetting(super.name, super.value, [this.minValue, this.maxValue]);

  bool validSetting(double val) {
    if (maxValue != null && val > maxValue!) {
      return false;
    } else if (minValue != null && val < minValue!) {
      return false;
    } else {
      return true;
    }
  }

  @override
  set value(double val) {
    if (maxValue != null && val > maxValue!) {
      value = maxValue!;
    } else if (minValue != null && val < minValue!) {
      value = minValue!;
    } else {
      value = val;
    }
  }
}

class PlayerSetting extends ArchipelabuttUserSetting<Player?> {
  PlayerSetting(super.name, super.value);
}
