import 'dart:async';
import 'dart:developer';

import 'package:buttplug/buttplug.dart';
import 'package:logging/logging.dart';
import 'package:archipelago/archipelago.dart';

import 'device/device_manager.dart';
import 'archipelago_connection.dart';
import 'buttplug_connection.dart';

class ArchipelabuttState {
  final ArchipelagoConnection apConn;
  final ButtplugConnection bpConn = ButtplugConnection();
  Stream<ArchipelagoEvent> get apStream => apConn.stream;
  final DeviceManager bpDevices = DeviceManager();

  ArchipelabuttState(String uuid) : apConn = ArchipelagoConnection(uuid) {
    apConn.stream.listen((event) {
      if (event is RoomUpdate) {
        apConn.client?.applyRoomUpdate(event);
      }
      bpDevices.handleArchipelagoEvent(event);
    });
    bpConn.stream.listen((event) {
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
  }
}
