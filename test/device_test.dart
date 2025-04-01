// Device unit tests
import 'package:archipelabutt/state/device/device.dart';
import 'package:buttplug/buttplug.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<ButtplugClientDevice>(),
  MockSpec<ClientGenericDeviceMessageAttributes>(),
  MockSpec<ClientDeviceMessageAttributes>(),
])
import 'device_test.mocks.dart';

void main() {
  group('Simple vibrator tests', () {
    MockButtplugClientDevice mockDevice = MockButtplugClientDevice();
    MockClientDeviceMessageAttributes mockAttributes =
        MockClientDeviceMessageAttributes();
    MockClientGenericDeviceMessageAttributes mockFeature =
        MockClientGenericDeviceMessageAttributes();

    setUp(() {
      when(mockFeature.actuatorType).thenReturn(ActuatorType.Vibrate);
      when(mockFeature.featureDescriptor).thenReturn('');
      when(mockFeature.stepCount).thenReturn(5);
      when(mockDevice.messageAttributes).thenReturn(mockAttributes);
      when(mockAttributes.scalarCmd).thenReturn([mockFeature]);
      when(mockAttributes.linearCmd).thenReturn([]);
      when(mockAttributes.rotateCmd).thenReturn([]);
      when(mockDevice.index).thenReturn(1);
      when(mockDevice.name).thenReturn('Test vibrator');
      when(mockDevice.displayName).thenReturn(null);
    });

    tearDown(() {
      reset(mockDevice);
      reset(mockAttributes);
      reset(mockFeature);
    });

    test('Device setup', () {
      Device device = Device(mockDevice);
      expect(device.scalarFeatureControllers.length, equals(1));
      expect(device.name, equals('Test vibrator'));
      expect(device.displayName, equals(null));
      expect(device.index, equals(1));
    });
  });
}
