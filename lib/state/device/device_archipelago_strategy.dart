import 'package:archipelabutt/state/device/device.dart';
import 'package:archipelabutt/state/device/strategy_result.dart';
import 'package:archipelago/archipelago.dart';

sealed class DeviceArchipelagoStrategy<T> {
  StrategyResult<T>? handleArchipelagoEvent(ArchipelagoEvent event);
  StrategyResult<T>? commandCompleted();
}

class DemoScalarStrategy extends DeviceArchipelagoStrategy<double> {
  final normalCheck = TimedCommand(0.5, Duration(milliseconds: 5000));
  final trapCheck = TimedCommand(0.0, Duration(milliseconds: 10000));
  final usefulCheck = TimedCommand(0.7, Duration(milliseconds: 5000));
  final advancementCheck = TimedCommand(1.0, Duration(milliseconds: 5000));
  final usefulAdvancementCheck = TimedCommand(
    1.0,
    Duration(milliseconds: 10000),
  );
  final baseCommand = 0.3;
  // TODO: Better place for this
  Player? trackedPlayer;

  @override
  StrategyResult<double>? handleArchipelagoEvent(ArchipelagoEvent event) {
    if (event is ItemSend) {
      final item = event.item;
      if (item.player.id == trackedPlayer?.id) {
        if (item.item.logicalAdvancement && item.item.useful) {
          return usefulAdvancementCheck;
        } else if (item.item.logicalAdvancement) {
          return advancementCheck;
        } else if (item.item.useful) {
          return usefulCheck;
        } else if (item.item.trap) {
          return trapCheck;
        } else {
          return normalCheck;
        }
      }
    }

    return null;
  }

  @override
  StrategyResult<double>? commandCompleted() {
    return Command(baseCommand);
  }
}

class DemoLinearStrategy extends DeviceArchipelagoStrategy<LinearCommand> {
  final TimedCommand<LinearCommand> normalCheck = TimedCommand(
    LinearCommand(0.5, 1.0, Duration(milliseconds: 750)),
    Duration(milliseconds: 4500),
  );
  final TimedCommand<LinearCommand> trapCheck = TimedCommand(
    LinearCommand(0.8, 1.0, Duration(milliseconds: 1000)),
    Duration(milliseconds: 10000),
  );
  final TimedCommand<LinearCommand> usefulCheck = TimedCommand(
    LinearCommand(0.3, 1.0, Duration(milliseconds: 750)),
    Duration(milliseconds: 4500),
  );
  final TimedCommand<LinearCommand> advancementCheck = TimedCommand(
    LinearCommand(0.5, 1.0, Duration(milliseconds: 500)),
    Duration(milliseconds: 5000),
  );
  final TimedCommand<LinearCommand> usefulAdvancementCheck = TimedCommand(
    LinearCommand(0.3, 1.0, Duration(milliseconds: 500)),
    Duration(milliseconds: 5000),
  );
  final baseCommand = LinearCommand(0.5, 1.0, Duration(milliseconds: 1000));
  // TODO: Better place for this
  Player? trackedPlayer;

  @override
  StrategyResult<LinearCommand>? handleArchipelagoEvent(
    ArchipelagoEvent event,
  ) {
    if (event is ItemSend) {
      final item = event.item;
      if (item.player.id == trackedPlayer?.id) {
        if (item.item.logicalAdvancement && item.item.useful) {
          return usefulAdvancementCheck;
        } else if (item.item.logicalAdvancement) {
          return advancementCheck;
        } else if (item.item.useful) {
          return usefulCheck;
        } else if (item.item.trap) {
          return trapCheck;
        } else {
          return normalCheck;
        }
      }
    }

    return null;
  }

  @override
  StrategyResult<LinearCommand>? commandCompleted() {
    return Command(baseCommand);
  }
}
