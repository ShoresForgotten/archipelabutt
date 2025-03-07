import 'package:archipelabutt/state/archipelabutt_device.dart';
import 'package:archipelago/archipelago.dart';

abstract interface class ArchipelabuttPointsSystem {
  List<ArchipelabuttUserSetting<dynamic>> get settings;
  double pointsChange(ArchipelagoEvent event, [double currentLevel]);
}
