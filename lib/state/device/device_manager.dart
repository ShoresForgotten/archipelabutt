import 'dart:collection';

import 'package:archipelabutt/state/device/device_controller.dart';
import 'package:archipelago/archipelago.dart';
import 'package:buttplug/buttplug.dart' as buttplug;
import 'package:flutter/material.dart';

// TODO: Get devices on connect, remove all on disconnect
class DeviceManager with ChangeNotifier {
  final Map<int, DeviceController> _devices = {};
  UnmodifiableMapView<int, DeviceController> get devices =>
      UnmodifiableMapView(_devices);

  void addDevice(buttplug.ButtplugClientDevice device) {
    _devices[device.index] = DeviceController(device);
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
  }

  void handleArchipelagoEvent(ArchipelagoEvent event) {
    for (final device in _devices.values) {
      device.handleArchipelagoEvent(event);
    }
  }
}
