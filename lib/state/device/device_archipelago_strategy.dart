import 'dart:async';

import 'package:archipelabutt/state/device/device.dart';
import 'package:archipelago/archipelago.dart';

abstract interface class DeviceArchipelagoStrategy<T> {
  Stream<T> get commands;
}

class ScalarCheckReward implements DeviceArchipelagoStrategy<double> {
  final double normalCheckIntensity = 0.5;
  final Duration normalCheckDuration = Duration(milliseconds: 5000);
  final double trapCheckIntensity = 0.0;
  final Duration trapCheckDuration = Duration(milliseconds: 10000);
  final double usefulCheckIntensity = 0.7;
  final Duration usefulCheckDuration = Duration(milliseconds: 5000);
  final double advancementCheckIntensity = 1.0;
  final Duration advancementCheckDuration = Duration(milliseconds: 5000);
  final double baseIntensity = 0.3;
  // TODO: Better place for this
  Player? trackedPlayer;

  final StreamController<double> _streamController =
      StreamController.broadcast();

  @override
  Stream<double> get commands => _streamController.stream;

  ScalarCheckReward() {
    // TODO: Set up stream
    throw UnimplementedError();
  }
}

class LinearCheckReward implements DeviceArchipelagoStrategy<LinearCommand> {
  final LinearCommand normalCheckIntensity = LinearCommand(
    0.5,
    1.0,
    Duration(milliseconds: 750),
  );
  final Duration normalCheckDuration = Duration(milliseconds: 4500);
  final LinearCommand trapCheckIntensity = LinearCommand(
    0.8,
    1.0,
    Duration(milliseconds: 1000),
  );
  final Duration trapCheckDuration = Duration(milliseconds: 10000);
  final LinearCommand usefulCheckIntensity = LinearCommand(
    0.3,
    1.0,
    Duration(milliseconds: 750),
  );
  final Duration usefulCheckDuration = Duration(milliseconds: 4500);
  final LinearCommand advancementCheckIntensity = LinearCommand(
    0.5,
    1.0,
    Duration(milliseconds: 500),
  );
  final Duration advancementCheckDuration = Duration(milliseconds: 5000);
  final baseCommand = LinearCommand(0.5, 1.0, Duration(milliseconds: 1000));
  // TODO: Better place for this
  Player? trackedPlayer;

  final StreamController<LinearCommand> _streamController =
      StreamController.broadcast();

  @override
  Stream<LinearCommand> get commands => _streamController.stream;

  LinearCheckReward() {
    // TODO: Set up stream
    throw UnimplementedError();
  }
}
