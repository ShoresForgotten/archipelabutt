import 'dart:collection';

import 'package:archipelabutt/state/device/device_controller.dart';
import 'package:buttplug/buttplug.dart' as buttplug;
import 'package:flutter/material.dart';

class DeviceManager with ChangeNotifier {
  final Map<int, DeviceController> _devices = {};
  UnmodifiableMapView<int, DeviceController> get devices =>
      UnmodifiableMapView(_devices);

  void _addDevice(buttplug.ButtplugClientDevice device) {
    _devices[device.index] = DeviceController(device);
  }

  void addDevice(buttplug.ButtplugClientDevice device) {
    _addDevice(device);
    notifyListeners();
  }

  void removeDevice(buttplug.ButtplugClientDevice device) {
    _devices.remove(device.index);
    notifyListeners();
  }

  void addMultipleDevices(List<buttplug.ButtplugClientDevice> devices) {
    for (final device in devices) {
      addDevice(device);
    }
    notifyListeners();
  }

  void clearDevices() {
    _devices.clear();
    notifyListeners();
  }
}
