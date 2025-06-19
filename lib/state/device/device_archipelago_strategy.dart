import 'dart:async';

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
