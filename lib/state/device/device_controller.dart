import 'dart:async';
import 'package:archipelabutt/state/device/device.dart';
import 'package:archipelabutt/state/device/device_archipelago_strategy.dart';
import 'package:archipelabutt/state/device/strategy_result.dart';
import 'package:archipelago/archipelago.dart';
import 'package:buttplug/buttplug.dart' as buttplug;

class DeviceController {
  final Device _device;
  String get name => _device.name;
  String? get displayName => _device.displayName;

  // TODO: Find a more appropriate place for some of the below
  final DemoLinearStrategy linearStrategy = DemoLinearStrategy();
  final DemoScalarStrategy scalarStrategy = DemoScalarStrategy();
  Timer? linearCommandTimer;
  Timer? scalarCommandTimer;

  bool hasLinear = false;
  bool hasScalar = false;

  DeviceController._(this._device, this.hasScalar, this.hasLinear);

  factory DeviceController(buttplug.ButtplugClientDevice bpDevice) {
    Device device = Device(bpDevice);
    bool scalar = false;
    if (device.scalarFeatureControllers.isNotEmpty) {
      scalar = true;
    }
    bool linear = false;
    if (device.linearFeatureControllers.isNotEmpty) {
      linear = true;
    }
    return DeviceController._(device, scalar, linear);
  }

  void stop() {
    linearCommandTimer?.cancel();
    scalarCommandTimer?.cancel();
    _device.stop();
  }

  void handleArchipelagoEvent(ArchipelagoEvent event) {
    final linearCommand = linearStrategy.handleArchipelagoEvent(event);
    if (linearCommand != null) {
      _handleLinearStrategyResult(linearCommand);
    }
    final scalarCommand = scalarStrategy.handleArchipelagoEvent(event);
    if (scalarCommand != null) {
      _handleScalarStrategyResult(scalarCommand);
    }
  }

  void _handleLinearStrategyResult(StrategyResult<LinearCommand> command) {
    linearCommandTimer?.cancel();
    _commandAllLinears(command.command);
    switch (command) {
      case TimedCommand():
        linearCommandTimer = Timer(command.duration, () {
          var command = linearStrategy.commandCompleted();
          if (command != null) {
            _handleLinearStrategyResult(command);
          }
        });
        break;
      case Command():
        break;
    }
  }

  void _handleScalarStrategyResult(StrategyResult<double> command) {
    scalarCommandTimer?.cancel();
    _commandAllScalars(command.command);
    switch (command) {
      case TimedCommand():
        scalarCommandTimer = Timer(command.duration, () {
          var command = scalarStrategy.commandCompleted();
          if (command != null) {
            _handleScalarStrategyResult(command);
          }
        });
        break;
      case Command():
        break;
    }
  }

  void _commandAllLinears(LinearCommand command) {
    for (final controller in _device.linearFeatureControllers) {
      controller.setCommand(command);
    }
  }

  void _commandAllScalars(double intensity) {
    for (final controller in _device.scalarFeatureControllers) {
      controller.setCommand(intensity);
    }
  }
}
