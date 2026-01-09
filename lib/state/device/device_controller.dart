import 'dart:async';
import 'dart:math' hide log;

import 'package:archipelabutt/state/device/device.dart';
import 'package:buttplug/buttplug.dart' as buttplug;
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class DeviceController {
  final Device _device;
  String get name => _device.name;
  String? get displayName => _device.displayName;
  final List<ScalarFeatureController> _features = [];
  UnmodifiableListView<ScalarFeatureController> get features =>
      UnmodifiableListView(_features);
  CheckOption activateOn = CheckOption.disabled;

  DeviceController(buttplug.ButtplugClientDevice bpDevice)
    : _device = Device(bpDevice) {
    for (final feature in _device.scalarFeatures) {
      _features.add(ScalarFeatureController(feature));
    }
  }

  void stop() {
    _device.stop();
  }

  void activate(CheckOption sentReceived, ItemType itemType) {
    if (activateOn == sentReceived) {
      for (final feature in _features) {
        feature.activate(itemType);
      }
    }
  }
}

class ScalarFeatureController {
  final ScalarFeature _feature;
  String get featureDescriptor =>
      _feature.featureDescriptor != ''
          ? _feature.featureDescriptor
          : _feature.actuatorType.name;
  int get steps => _feature.stepCount;
  final Map<ItemType, ScalarActivationInfo> activationInfo = {
    for (var i in ItemType.values) i: ScalarActivationInfo(),
  };
  Timer? currentTimer;

  ScalarFeatureController(this._feature);

  void activate(ItemType type) {
    if (currentTimer?.isActive ?? false) {
      currentTimer!.cancel();
    }
    final info = activationInfo[type]!;
    _feature.setIntensity(info._intensity);
    currentTimer = Timer(Duration(milliseconds: info.duration), () {
      _feature.setIntensity(0.0);
    });
  }
}

class ScalarActivationInfo {
  int _duration;
  set duration(int time) {
    _duration = max(time, 100);
  }

  int get duration => _duration;
  double _intensity;
  set intensity(double i) {
    _intensity = clampDouble(i, 0.0, 1.0);
  }

  double get intensity => _intensity;

  ScalarActivationInfo({duration = 1000, intensity = 1.0})
    : _duration = max(duration, 100),
      _intensity = clampDouble(intensity, 0.0, 1.0);
}

enum CheckOption { sent, received, disabled }

enum ItemType { regular, logical, useful, trap }
