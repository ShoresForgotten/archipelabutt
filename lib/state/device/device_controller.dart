import 'dart:async';
import 'dart:math';
import 'package:buttplug/buttplug.dart';

class DeviceController {
  final ButtplugClientDevice _device;
  String get name => _device.name;
  String? get displayName => _device.displayName;
  StreamSubscription<double>? _scalarSubscription;

  DeviceController(this._device);

  Future<void> setScalarSource(Stream<double> scalarStream) async {
    await _scalarSubscription?.cancel();
    _scalarSubscription = scalarStream.listen(
      (double scalarCommand) => _commandAllScalars(scalarCommand),
    );
  }

  void stop() {
    _commandAllScalars(0);
  }

  /*
  I'll do feature-level granularity eventually.
  It'd also be nice for the purposes of step count UI stuff
  */

  void _commandAllScalars(double intensity) {
    for (final feature in _device.features) {
      var actuator = feature.feature.actuator;
      if (actuator != null) {
        var stepCount = actuator.stepCount;
        int level = max((stepCount * intensity).floor(), stepCount);
        switch (feature.feature.featureType) {
          case "Vibrate":
            feature.vibrate(level);
          case "Oscillate":
            feature.oscillate(level);
          default:
            continue;
        }
      }
    }
  }
}
