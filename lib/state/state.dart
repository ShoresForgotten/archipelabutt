import 'dart:async';
import 'dart:developer';

import 'package:archipelabutt/state/archipelabutt_device.dart';
import 'package:archipelabutt/state/archipelago_connection.dart';
import 'package:archipelabutt/state/buttplug_connection.dart';
import 'package:buttplug/buttplug.dart';
import 'package:logging/logging.dart';

import '../archipelago/archipelago.dart';

class ArchipelabuttState {
  final ArchipelagoConnection apConn;
  final ButtplugConnection bpConn = ButtplugConnection();
  Stream<ArchipelagoEvent> get apStream => apConn.stream;
  final ArchipelabuttDeviceIndex bpDevices = ArchipelabuttDeviceIndex();

  ArchipelabuttState(String uuid) : apConn = ArchipelagoConnection(uuid) {
    apConn.stream.listen((event) {
      if (event is RoomUpdate) {
        apConn.client?.applyRoomUpdate(event);
      }
      bpDevices.handleEvent(event);
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
