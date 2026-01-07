import 'dart:async';
import 'dart:developer';

import 'package:buttplug/buttplug.dart';
import 'package:logging/logging.dart';
import 'package:archipelago/archipelago.dart';

import 'device/device_manager.dart';
import 'archipelago_connection.dart';
import 'buttplug_connection.dart';

class ArchipelabuttState {
  ArchipelagoConnection? _apConn;
  ButtplugConnection? _bpConn;
  Stream<ArchipelagoEvent>? get apStream => _apConn?.stream;
  final DeviceManager bpDevices = DeviceManager();

  ArchipelabuttState();

  set bpConn(ButtplugConnection conn) {
    bpDevices.clearDevices();
    conn.stream.listen((event) {
      log(event.toString(), level: Level.INFO.value);
      switch (event) {
        case DeviceAddedEvent():
          bpDevices.addDevice(event.device);
          break;
        case DeviceRemovedEvent():
          bpDevices.removeDevice(event.device);
          break;
      }
    });
    _bpConn = conn;
  }

  set apConn(ArchipelagoConnection conn) {
    _apConn = conn;
    // TODO: Send signals to devices
  }
}
