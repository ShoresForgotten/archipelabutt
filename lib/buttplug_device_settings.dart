import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/archipelabutt_device.dart';

class ButtplugDeviceSettings extends StatefulWidget {
  const ButtplugDeviceSettings({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ButtplugDeviceSettingsState();
  }
}

class _ButtplugDeviceSettingsState extends State<ButtplugDeviceSettings> {
  ArchipelabuttDevice? selectedDevice;
  ArchipelabuttDeviceFeature? selectedFeature;

  @override
  Widget build(BuildContext context) {
    return Consumer<ArchipelabuttDeviceIndex>(
      builder: (context, value, child) {
        if (!value.devices.containsValue(selectedDevice)) {
          selectedDevice = null;
          selectedFeature = null;
        }
        final List<ArchipelabuttDeviceFeature> features = [];
        selectedDevice?.scalarFeatures?.forEach(
          (element) => features.add(element),
        );
        return Column(
          children: [
            Row(
              children: [
                DropdownMenu<ArchipelabuttDevice>(
                  dropdownMenuEntries:
                      value.devices.values
                          .map(
                            (x) => DropdownMenuEntry(value: x, label: x.name),
                          )
                          .toList(),
                  onSelected: (ArchipelabuttDevice? device) {
                    setState(() {
                      selectedDevice = device;
                    });
                  },
                ),
                DropdownMenu<ArchipelabuttDeviceFeature>(
                  dropdownMenuEntries:
                      features
                          .map(
                            (e) => DropdownMenuEntry(
                              value: e,
                              label: e.description,
                            ),
                          )
                          .toList(),
                  onSelected: (ArchipelabuttDeviceFeature? value) {
                    setState(() {
                      selectedFeature = value;
                    });
                  },
                ),
              ],
            ),
            Divider(),
            _ButtplugStrategySettings(feature: selectedFeature),
          ],
        );
      },
    );
  }
}

class _ButtplugStrategySettings extends StatelessWidget {
  final ArchipelabuttDeviceFeature? feature;

  const _ButtplugStrategySettings({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    if (feature != null) {
      return Column(
        children: [
          DropdownMenu<ArchipelabuttStrategy>(
            dropdownMenuEntries:
                feature!.availableStrategies
                    .map((x) => DropdownMenuEntry(label: x.name, value: x))
                    .toList(),
            onSelected: (value) {
              if (value != null) {
                feature!.activeStrategy = value;
              }
            },
            initialSelection: feature!.activeStrategy,
          ),
          Divider(),
        ],
      );
    } else {
      return Text('Select a device and feature');
    }
  }
}

class _ButtplugIndividualSettings extends StatelessWidget {
  final List<ArchipelabuttUserSetting> settings;

  const _ButtplugIndividualSettings({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    //TODO
    throw UnimplementedError();
  }
}

abstract class _ArchipelabuttSetting<T> extends FormField {
  const _ArchipelabuttSetting({super.key, required super.builder});
}
