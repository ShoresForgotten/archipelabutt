import 'dart:async';
import 'dart:developer';

import 'package:buttplug/buttplug.dart' as buttplug;
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';

class Device {
  final buttplug.ButtplugClientDevice _device;
  String get name => _device.name;
  String? get displayName => _device.displayName;
  int get index => _device.index;
  final List<ScalarFeatureController> _scalarFeatureControllers = [];
  UnmodifiableListView<ScalarFeatureController> get scalarFeatureControllers =>
      UnmodifiableListView(_scalarFeatureControllers);

  Device(this._device) {
    final scalarFeatures = _device.messageAttributes.scalarCmd ?? [];
    for (var (index, feature) in scalarFeatures.indexed) {
      _scalarFeatureControllers.add(
        ScalarFeatureController(_device, index, feature),
      );
    }
  }

  void stop() {
    for (final feature in scalarFeatureControllers) {
      feature.stop();
    }
  }
}

sealed class FeatureController<T extends DeviceFeature> {
  final T _feature;
  String get featureDescriptor => _feature.featureDescriptor;

  FeatureController(this._feature);

  void stop();
}

class ScalarFeatureController extends FeatureController<ScalarFeature> {
  ScalarFeatureController(
    buttplug.ButtplugClientDevice device,
    int featureIndex,
    buttplug.ClientGenericDeviceMessageAttributes featureInfo,
  ) : super(ScalarFeature(device, featureIndex, featureInfo));

  void setCommand(double intensity) {
    if (intensity < 0.0 || intensity > 1.0) {
      Error();
    }
    _feature.setIntensity(intensity);
  }

  @override
  void stop() {
    setCommand(0.0);
  }
}

sealed class DeviceFeature {
  final buttplug.ButtplugClientDevice _device;
  final buttplug.ClientGenericDeviceMessageAttributes _featureInfo;
  String get featureDescriptor => _featureInfo.featureDescriptor;
  final int _featureIndex;
  DeviceFeature(this._device, this._featureIndex, this._featureInfo);
}

class ScalarFeature extends DeviceFeature {
  buttplug.ActuatorType get _actuatorType => _featureInfo.actuatorType;
  ScalarFeature(super.device, super.featureIndex, super.featureInfo);

  void setIntensity(double intensity) {
    final buttplug.ScalarComponent component = buttplug.ScalarComponent(
      intensity,
      _actuatorType,
    );
    final buttplug.ScalarCommand command = buttplug.ScalarCommand.setMap({
      _featureIndex: component,
    });
    _device.scalar(command);
  }
}
