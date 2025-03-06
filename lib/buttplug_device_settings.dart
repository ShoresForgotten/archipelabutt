import 'package:archipelabutt/state/archipelago_connection.dart';
import 'package:archipelago/archipelago.dart';
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
            _ButtplugStrategySelection(feature: selectedFeature),
            Divider(),
          ],
        );
      },
    );
  }
}

class _ButtplugStrategySelection extends StatelessWidget {
  final ArchipelabuttDeviceFeature? feature;

  const _ButtplugStrategySelection({required this.feature});

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
          _ButtplugStrategySettings(strategy: feature!.activeStrategy),
        ],
      );
    } else {
      return Text('No feature selected');
    }
  }
}

class _ButtplugStrategySettings extends StatelessWidget {
  final ArchipelabuttStrategy strategy;

  const _ButtplugStrategySettings({required this.strategy});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children:
            strategy.settings
                .map((e) => _ArchipelabuttUserSettingWidget(setting: e))
                .toList(),
      ),
    );
  }
}

class _ArchipelabuttUserSettingWidget extends StatelessWidget {
  final ArchipelabuttUserSetting setting;

  const _ArchipelabuttUserSettingWidget({super.key, required this.setting});

  @override
  Widget build(BuildContext context) {
    switch (setting) {
      case PlayerSetting():
        return _ArchipelabuttPlayerSettingWidget(
          setting: setting as PlayerSetting,
        );
      case DoubleSetting():
        return _ArchipelabuttDoubleSettingWidget(
          setting: setting as DoubleSetting,
        );
    }
  }
}

class _ArchipelabuttPlayerSettingWidget extends StatelessWidget {
  final PlayerSetting setting;

  const _ArchipelabuttPlayerSettingWidget({super.key, required this.setting});

  @override
  Widget build(BuildContext context) {
    // TODO: Consider changing state management to avoid this Consumer
    return Consumer<ArchipelagoConnection>(
      builder: (context, value, child) {
        return FormField<Player>(
          builder: (field) {
            return DropdownMenu(
              dropdownMenuEntries:
                  value.client?.players
                      .map((e) => DropdownMenuEntry(value: e, label: e.name))
                      .toList() ??
                  [],
              initialSelection: setting.value,
            );
          },
          onSaved: (newValue) {
            setting.value = newValue;
          },
        );
      },
    );
  }
}

class _ArchipelabuttDoubleSettingWidget extends StatelessWidget {
  final DoubleSetting setting;

  const _ArchipelabuttDoubleSettingWidget({super.key, required this.setting});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(label: Text(setting.name)),
      validator: (String? input) {
        if (input != null) {
          final parsed = double.tryParse(input);
          if (parsed != null) {
            if (setting.maxValue != null && parsed > setting.maxValue!) {
              // TODO: This better
              return 'Input is larger than max value';
            } else if (setting.minValue != null && parsed < setting.minValue!) {
              return 'Input is smaller than minimum value';
            }
          } else {
            // TODO: Limit inputs
            return 'Input is not a number';
          }
        } else {
          return 'Field cannot be empty';
        }
      },
      onSaved: (newValue) {
        setting.value = double.parse(newValue!);
      },
      initialValue: setting.value.toString(),
    );
  }
}
