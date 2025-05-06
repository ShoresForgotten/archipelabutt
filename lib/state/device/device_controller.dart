import 'dart:async';
import 'package:archipelabutt/state/device/device.dart';
import 'package:buttplug/buttplug.dart' as buttplug;

class DeviceController {
  final Device _device;
  String get name => _device.name;
  String? get displayName => _device.displayName;
  StreamSubscription<LinearCommand>? _linearSubscription;
  StreamSubscription<double>? _scalarSubscription;

  bool hasLinear = false;
  bool hasScalar = false;

  DeviceController._(this._device, this.hasScalar, this.hasLinear);

  factory DeviceController(buttplug.ButtplugClientDevice bpDevice) {
    Device device = Device(bpDevice);
    bool scalar = false;
    if (device.scalarFeatureControllers.isNotEmpty) {
      scalar = true;
    }
    bool linear = false;
    if (device.linearFeatureControllers.isNotEmpty) {
      linear = true;
    }
    return DeviceController._(device, scalar, linear);
  }

  Future<void> setLinearSource(Stream<LinearCommand> linearStream) async {
    await _linearSubscription?.cancel();
    _linearSubscription = linearStream.listen(
      (LinearCommand linearCommand) => _commandAllLinears(linearCommand),
    );
  }

  Future<void> setScalarSource(Stream<double> scalarStream) async {
    await _scalarSubscription?.cancel();
    _scalarSubscription = scalarStream.listen(
      (double scalarCommand) => _commandAllScalars(scalarCommand),
    );
  }

  void stop() {
    _device.stop();
  }

  /*
  It'd be neat to have support for feature-level granularity for strategies,
  but as things are in the current version of buttplug.io, that'd be hard to do.
  v4 of the spec plans to switch from message attributes to device features,
  but that's not done yet. When it is, it'll be worth considering the above.
  */
  void _commandAllLinears(LinearCommand command) {
    for (final controller in _device.linearFeatureControllers) {
      controller.setCommand(command);
    }
  }

  void _commandAllScalars(double intensity) {
    for (final controller in _device.scalarFeatureControllers) {
      controller.setCommand(intensity);
    }
  }
}
