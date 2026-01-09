import 'dart:async';
import 'dart:developer';

import 'package:buttplug/buttplug.dart';
import 'package:logging/logging.dart';
import 'package:archipelago/archipelago.dart';
import 'package:flutter/foundation.dart';

import 'device/device_manager.dart';
import 'archipelago_connection.dart';
import 'buttplug_connection.dart';
import 'device/device_controller.dart';

class ArchipelabuttState with ChangeNotifier {
  ArchipelagoConnection? _apConn;
  ButtplugConnection? _bpConn;
  Stream<ArchipelagoEvent>? get apStream => _apConn?.stream;
  final DeviceManager bpDevices = DeviceManager();

  bool get apConnected => _apConn?.connected ?? false;
  bool get bpConnected => _bpConn?.connected ?? false;

  ArchipelabuttState();

  set bpConn(ButtplugConnection conn) {
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

    conn.addListener(() {
      if (conn.connected == false) {
        bpDevices.clearDevices();
      }
      notifyListeners();
    });

    bpDevices.addMultipleDevices(conn.client.devices.values.toList());

    _bpConn = conn;
    notifyListeners();
  }

  set apConn(ArchipelagoConnection conn) {
    _apConn = conn;
    // TODO: Send signals to devices
    conn.stream.listen((event) {
      if (event is ItemSend) {
        _activateDevices(event);
      }
    });
    conn.addListener(() => notifyListeners());
    notifyListeners();
  }

  void _activateDevices(ItemSend message) {
    log(message.toString(), level: 0);
    //TODO: Improve archipelago library so I don't have to do this like this
    final player = _apConn!.connectionParamaters.name;
    final item = message.item.item;
    //TODO: This better
    ItemType itemType = ItemType.regular;
    if (item.logicalAdvancement) {
      itemType = ItemType.logical;
    } else if (item.useful) {
      itemType = ItemType.useful;
    } else if (item.trap) {
      itemType = ItemType.trap;
    }
    for (final device in bpDevices.devices.values) {
      if (message.receiving.name == player) {
        device.activate(CheckOption.received, itemType);
      }
      if (message.item.player.name == player) {
        device.activate(CheckOption.sent, itemType);
      }
    }
  }
}
