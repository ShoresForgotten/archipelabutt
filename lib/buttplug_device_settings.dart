import 'package:archipelabutt/state/device/device_controller.dart';
import 'package:archipelabutt/state/device/device_manager.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO: Make all of this work

class ButtplugSettings extends StatefulWidget {
  const ButtplugSettings({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ButtplugSettingsState();
  }
}

class _ButtplugSettingsState extends State<ButtplugSettings> {
  DeviceController? selectedDevice;

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceManager>(
      builder: (context, value, child) {
        if (!value.devices.containsValue(selectedDevice)) {
          selectedDevice = null;
        }
        List<ListTile> deviceTiles =
            value.devices.entries.sortedBy((x) => x.key).map((entry) {
              return ListTile(
                title: Text(entry.value.name),
                onTap: () => selectedDevice = entry.value,
                selected: selectedDevice == entry.value,
              );
            }).toList();
        // TODO: Make this work for portrait aspect ratios
        return Row(
          children: [
            Expanded(child: ListView(children: deviceTiles)),
            Expanded(child: _ButtplugDeviceSettings(device: selectedDevice)),
          ],
        );
      },
    );
  }
}

class _ButtplugDeviceSettings extends StatefulWidget {
  final DeviceController? device;
  // ignore: unused_element_parameter
  const _ButtplugDeviceSettings({super.key, required this.device});

  @override
  State<_ButtplugDeviceSettings> createState() =>
      _ButtplugDeviceSettingsState();
}

class _ButtplugDeviceSettingsState extends State<_ButtplugDeviceSettings> {
  @override
  Widget build(BuildContext context) {
    if (widget.device == null) {
      return Text("No device selected");
    }
    DeviceController device = widget.device!;
    return Placeholder();
  }
}
