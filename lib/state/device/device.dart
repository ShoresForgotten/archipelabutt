import 'dart:async';
import 'dart:developer';

import 'package:buttplug/buttplug.dart' as buttplug;
import 'package:collection/collection.dart';

class Device {
  final buttplug.ButtplugClientDevice _device;
  String get name => _device.name;
  String? get displayName => _device.displayName;
  int get index => _device.index;
  final List<ScalarFeatureController> _scalarFeatureControllers = [];
  UnmodifiableListView<ScalarFeatureController> get scalarFeatureControllers =>
      UnmodifiableListView(_scalarFeatureControllers);
  final List<LinearFeatureController> _linearFeatureControllers = [];
  UnmodifiableListView<LinearFeatureController> get linearFeatureControllers =>
      UnmodifiableListView(_linearFeatureControllers);
  // TODO: Implement rotation

  Device(this._device) {
    if (_device.name != 'Lovense Solace Pro') {
      // The solace pro has both a position and oscillate feature in buttplug.io
      // We're using the position, so we don't want the oscillation
      final scalarFeatures = _device.messageAttributes.scalarCmd ?? [];
      for (var (index, feature) in scalarFeatures.indexed) {
        _scalarFeatureControllers.add(
          ScalarFeatureController(_device, index, feature),
        );
      }
    }
    final linearFeatures = _device.messageAttributes.linearCmd ?? [];
    for (var (index, feature) in linearFeatures.indexed) {
      _linearFeatureControllers.add(
        LinearFeatureController(_device, index, feature),
      );
    }
  }

  void stop() {
    for (final feature in scalarFeatureControllers) {
      feature.stop();
    }
    for (final feature in linearFeatureControllers) {
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

// TODO: Consider making a non-looping command type
class LinearFeatureController extends FeatureController<LinearFeature> {
  LinearCommand _currentCommand;
  Timer? _nextCommand;
  bool _toMin = false;

  LinearFeatureController(
    buttplug.ButtplugClientDevice device,
    int featureIndex,
    buttplug.ClientGenericDeviceMessageAttributes featureInfo,
  ) : _currentCommand = LinearCommand(0.0, 1.0, Duration(milliseconds: 1000)),
      super(LinearFeature(device, featureIndex, featureInfo));

  void setCommand(LinearCommand command) {
    _nextCommand?.cancel();
    _currentCommand = command;
    _runCommand();
  }

  void _runCommand() {
    if (_toMin) {
      _feature.goToPos(
        _currentCommand.minPosition,
        _currentCommand.speed.inMilliseconds,
      );
    } else {
      _feature.goToPos(
        _currentCommand.maxPosition,
        _currentCommand.speed.inMilliseconds,
      );
    }
    _nextCommand = Timer(_currentCommand.speed, () => _runCommand());
    _toMin = !_toMin;
  }

  @override
  void stop() {
    _nextCommand?.cancel();
  }
}

class LinearCommand {
  final double minPosition;
  final double maxPosition;
  final Duration speed;

  LinearCommand(this.minPosition, this.maxPosition, this.speed) {
    if (minPosition > maxPosition ||
        minPosition < 0.0 ||
        minPosition > 1.0 ||
        maxPosition < 0.0 ||
        maxPosition > 1.0 ||
        speed.inMilliseconds < 0) {
      Error();
    }
  }
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

// Rotation feature controller here

sealed class DeviceFeature {
  final buttplug.ButtplugClientDevice _device;
  final buttplug.ClientGenericDeviceMessageAttributes _featureInfo;
  String get featureDescriptor => _featureInfo.featureDescriptor;
  final int _featureIndex;
  DeviceFeature(this._device, this._featureIndex, this._featureInfo);
}

class LinearFeature extends DeviceFeature {
  LinearFeature(super.device, super.index, super.featureInfo);

  void goToPos(double pos, int speed) {
    final buttplug.LinearComponent component = buttplug.LinearComponent(
      pos,
      speed,
    );
    final buttplug.LinearCommand command = buttplug.LinearCommand.setMap({
      _featureIndex: component,
    });
    _device.linear(command);
  }
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

// Rotation feature here
