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
}
