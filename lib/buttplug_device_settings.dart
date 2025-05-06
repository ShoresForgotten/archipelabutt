import 'package:archipelabutt/state/archipelago_connection.dart';
import 'package:archipelabutt/state/device/device_controller.dart';
import 'package:archipelabutt/state/device/device_manager.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO: Make all of this work

class ButtplugDeviceSelection extends StatefulWidget {
  const ButtplugDeviceSelection({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ButtplugDeviceSelectionState();
  }
}

class _ButtplugDeviceSelectionState extends State<ButtplugDeviceSelection> {
  DeviceController? selectedDevice;

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceManager>(
      builder: (context, value, child) {
        if (!value.devices.containsValue(selectedDevice)) {
          selectedDevice = null;
        }
        return Column(
          children: [
            DropdownMenu<DeviceController>(
              dropdownMenuEntries:
                  value.devices.values
                      .map((x) => DropdownMenuEntry(value: x, label: x.name))
                      .toList(),
              onSelected: (DeviceController? device) {
                setState(() {
                  selectedDevice = device;
                });
              },
            ),
            Divider(),
            _ButtplugDeviceSettings(device: selectedDevice),
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
    return Consumer<ArchipelagoConnection>(
      builder: (context, conn, child) {
        if (widget.device != null) {
          DeviceController device = widget.device!;
          /*
          List<Widget> scalarSettings =
              device.hasScalar
                  ? <Widget>[
                    Text('Normal Check'),
                    Slider(
                      value: device.scalarStrategy.normalCheck.command,
                      onChanged:
                          (value) =>
                              device.scalarStrategy.normalCheck.command = value,
                      max: 1.0,
                      min: 0.0,
                    ),

                    Divider(),
                  ]
                  : [];
          List<Widget> linearSettings = device.hasLinear ? [] : [];
          */
          return Column(
            children: [
              Placeholder(),
              Divider(),
              //Column(children: scalarSettings),
              //Column(children: linearSettings),
            ],
          );
        } else {
          return Placeholder();
        }
      },
    );
  }
}
/*
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
              if (_strategySettingsFormKey.currentState?.validate() ?? false) {
                _strategySettingsFormKey.currentState?.save();
              }
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
          final parsed = double.parse(input);
          if (setting.maxValue != null && parsed > setting.maxValue!) {
            // TODO: This better
            return 'Input is larger than max value';
          } else if (setting.minValue != null && parsed < setting.minValue!) {
            return 'Input is smaller than minimum value';
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
*/