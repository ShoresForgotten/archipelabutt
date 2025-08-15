import 'dart:async';
import 'package:archipelabutt/state/device/device.dart';
import 'package:buttplug/buttplug.dart' as buttplug;

class DeviceController {
  final Device _device;
  String get name => _device.name;
  String? get displayName => _device.displayName;

  DeviceController._(this._device);

  factory DeviceController(buttplug.ButtplugClientDevice bpDevice) {
    Device device = Device(bpDevice);
    return DeviceController._(device);
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
}
