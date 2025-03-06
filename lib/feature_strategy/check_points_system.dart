import 'package:archipelabutt/feature_strategy/archipelabutt_points_system.dart';
import 'package:archipelabutt/state/archipelabutt_device.dart';
import 'package:archipelago/archipelago.dart';
import 'package:flutter/material.dart';

class CheckPointsSystem implements ArchipelabuttPointsSystem {
  final DoubleSetting basePointsValue;
  final DoubleSetting logicalAdvancementModifier;
  final DoubleSetting usefulModifier;
  final DoubleSetting trapModifier;
  PlayerSetting? trackedPlayer;

  CheckPointsSystem([
    double? basePointsValue,
    double? logicalAdvancementModifier,
    double? usefulModifier,
    double? trapModifier,
    Player? trackedPlayer,
  ]) : basePointsValue = DoubleSetting(
         'Base check value',
         basePointsValue ?? 0,
       ),
       logicalAdvancementModifier = DoubleSetting(
         'Logical advancement modifier',
         logicalAdvancementModifier ?? 0,
       ),
       usefulModifier = DoubleSetting('Useful item modifier', 0),
       trapModifier = DoubleSetting('Trap item modifier', 0);

  @override
  double pointsChange(ArchipelagoEvent event, [double currentLevel = 0]) {
    if (event is DisplayMessage &&
        event is ItemSend &&
        trackedPlayer != null &&
        event.item.player == trackedPlayer!.value) {
      var sum = currentLevel + basePointsValue.value;
      if (event.item.item.logicalAdvancement) {
        sum += logicalAdvancementModifier.value;
      }
      if (event.item.item.useful) sum += usefulModifier.value;
      if (event.item.item.trap) sum += trapModifier.value;
      return sum;
    } else {
      return currentLevel;
    }
  }

  @override
  List<ArchipelabuttUserSetting<dynamic>> get settings {
    final ret = <ArchipelabuttUserSetting<dynamic>>[
      basePointsValue,
      logicalAdvancementModifier,
      usefulModifier,
      trapModifier,
    ];
    if (trackedPlayer != null) {
      ret.add(trackedPlayer!);
    }
    return ret;
  }
}
