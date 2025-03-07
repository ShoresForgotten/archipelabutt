import 'package:archipelabutt/state/archipelago_connection.dart';
import 'package:archipelago/archipelago.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              // TODO: Make this stack vertically if needed
              children: [
                Expanded(
                  child: DropdownMenu<ArchipelabuttDevice>(
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
                ),
                Expanded(
                  child: DropdownMenu<ArchipelabuttDeviceFeature>(
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
                ),
              ],
            ),
            Divider(),
            _ButtplugStrategySelection(feature: selectedFeature),
          ],
        );
      },
    );
  }
}

class _ButtplugStrategySelection extends StatefulWidget {
  final ArchipelabuttDeviceFeature? feature;

  const _ButtplugStrategySelection({required this.feature});
  @override
  State<_ButtplugStrategySelection> createState() {
    return _ButtplugStrategySelectionState();
  }
}

class _ButtplugStrategySelectionState
    extends State<_ButtplugStrategySelection> {
  ArchipelabuttStrategy? selectedStrategy;

  final GlobalKey<FormState> _strategySettingsFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (widget.feature != null) {
      selectedStrategy = widget.feature!.activeStrategy;
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownMenu<ArchipelabuttStrategy>(
                  dropdownMenuEntries:
                      widget.feature!.availableStrategies
                          .map(
                            (x) => DropdownMenuEntry(label: x.name, value: x),
                          )
                          .toList(),
                  onSelected: (value) {
                    if (value != null) {
                      selectedStrategy = value;
                    }
                  },
                  initialSelection: widget.feature!.activeStrategy,
                ),
              ),
              FilledButton(
                onPressed: () {
                  if (selectedStrategy != null) {
                    widget.feature!.activeStrategy = selectedStrategy!;
                  }
                },
                child: Text('Set Strategy'),
              ),
            ],
          ),
          Divider(),
          _ButtplugStrategySettings(
            strategy: selectedStrategy!,
            formKey: _strategySettingsFormKey,
          ),
          Divider(),
          FilledButton(
            onPressed: () {
              _strategySettingsFormKey.currentState?.save();
            },
            child: Text('Save settings'),
          ),
        ],
      );
    } else {
      return Text('No feature selected');
    }
  }
}

class _ButtplugStrategySettings extends StatelessWidget {
  final ArchipelabuttStrategy strategy;
  final GlobalKey<FormState> formKey;

  const _ButtplugStrategySettings({
    required this.strategy,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.always,
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

  const _ArchipelabuttUserSettingWidget({required this.setting});

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

  const _ArchipelabuttPlayerSettingWidget({required this.setting});

  @override
  Widget build(BuildContext context) {
    // TODO: Consider changing state management to avoid this Consumer
    return Consumer<ArchipelagoConnection>(
      builder: (context, value, child) {
        return FormField<Player>(
          builder: (field) {
            return DropdownMenu<Player>(
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

// TODO: Do another pass over this
class _ArchipelabuttDoubleSettingWidget extends StatelessWidget {
  final DoubleSetting setting;

  const _ArchipelabuttDoubleSettingWidget({required this.setting});

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
          }
        } else {
          return 'Field cannot be empty';
        }
        return null;
      },
      onSaved: (newValue) {
        final parsed = double.tryParse(newValue!);
        if (parsed != null) {
          setting.value = parsed;
        }
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*\.?[0-9]*')),
      ],
      initialValue: setting.value.toString(),
    );
  }
}
