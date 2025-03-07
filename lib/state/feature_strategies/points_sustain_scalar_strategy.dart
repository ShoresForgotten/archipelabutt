import 'package:archipelabutt/state/feature_strategies/archipelabutt_points_system.dart';
import 'package:archipelabutt/state/feature_strategies/check_points_system.dart';
import 'package:archipelabutt/state/archipelabutt_device.dart';
import 'package:archipelago/archipelago.dart';
import 'package:buttplug/buttplug.dart';

class PointsSustainScalarStrategy implements ArchipelabuttScalarStrategy {
  @override
  final name = 'Check Giver';
  @override
  get settings => pointsSystem.settings;
  ArchipelabuttPointsSystem pointsSystem = CheckPointsSystem();
  double currentLevel = 0;

  PointsSustainScalarStrategy();
  @override
  ScalarComponent handleEvent(ArchipelagoEvent event, ActuatorType actuator) {
    currentLevel = pointsSystem.pointsChange(event, currentLevel).clamp(0, 1);
    return ScalarComponent(currentLevel, actuator);
  }
}
