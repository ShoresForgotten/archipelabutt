import 'package:buttplug/buttplug.dart' as buttplug;
import 'package:collection/collection.dart';

class Device {
  final buttplug.ButtplugClientDevice _device;
  String get name => _device.name;
  String? get displayName => _device.displayName;
  int get index => _device.index;
  final List<ScalarFeature> _scalarFeatures = [];
  UnmodifiableListView<ScalarFeature> get scalarFeatures =>
      UnmodifiableListView(_scalarFeatures);

  Device(this._device) {
    final scalarFeatures = _device.messageAttributes.scalarCmd ?? [];
    for (var (index, feature) in scalarFeatures.indexed) {
      _scalarFeatures.add(ScalarFeature(_device, index, feature));
    }
  }

  void stop() {
    for (final feature in scalarFeatures) {
      feature.stop();
    }
  }
}

sealed class DeviceFeature {
  final buttplug.ButtplugClientDevice _device;
  final buttplug.ClientGenericDeviceMessageAttributes _featureInfo;
  String get featureDescriptor => _featureInfo.featureDescriptor;
  int get stepCount => _featureInfo.stepCount;
  final int _featureIndex;
  DeviceFeature(this._device, this._featureIndex, this._featureInfo);

  void stop();
}

class ScalarFeature extends DeviceFeature {
  buttplug.ActuatorType get actuatorType => _featureInfo.actuatorType;
  ScalarFeature(super.device, super.featureIndex, super.featureInfo);

  void setIntensity(double intensity) {
    final buttplug.ScalarComponent component = buttplug.ScalarComponent(
      intensity,
      actuatorType,
    );
    final buttplug.ScalarCommand command = buttplug.ScalarCommand.setMap({
      _featureIndex: component,
    });
    _device.scalar(command);
  }

  @override
  void stop() {
    setIntensity(0.0);
  }
}
