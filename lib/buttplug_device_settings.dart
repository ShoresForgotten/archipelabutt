import 'package:archipelabutt/state/archipelabutt_device.dart';
import 'package:archipelabutt/state/state.dart';
import 'package:buttplug/buttplug.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'archipelago/archipelago.dart';

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
  ArchipelabuttStrategy? selectedStrategy;

  @override
  Widget build(BuildContext context) {
    return Consumer<ArchipelabuttDeviceIndex>(
      builder: (context, value, child) {
        if (!value.devices.containsValue(selectedDevice)) {
          selectedDevice = null;
          selectedFeature = null;
          selectedStrategy = null;
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
            Placeholder(),
          ],
        );
      },
    );
  }
}

class _ButtplugControllerSettingsArea extends StatelessWidget {
  final ArchipelabuttDeviceFeature? feature;
  const _ButtplugControllerSettingsArea({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    if (feature == null) {
      return Text('No device selected');
    } else {
      List<Widget> children = [];
      feature!.settings
          .map((e) => Placeholder())
          .forEach((element) => children.add(element));
      children.add(Divider());
      feature!.strategy.settings
          .map((e) {
            if (e is ArchipelabuttDoubleSetting) {
              return TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^-?[0-9]*\.?[0-9]*'),
                  ),
                ],
                controller: TextEditingController(text: e.value.toString()),
                decoration: InputDecoration(label: Text(e.label)),
                onChanged: (value) {
                  final newValue = double.tryParse(value);
                  if (newValue != null) {
                    e.value = newValue;
                  }
                },
              );
            } else if (e is ArchipelabuttUserSetting<Player>) {
              return TextField(
                maxLength: 16,
                controller: TextEditingController(text: e.value.name),
                decoration: InputDecoration(label: Text(e.label)),
                onChanged: (value) {
                  e.value = Player(value);
                },
              );
            }
            return Placeholder();
          })
          .forEach((e) => children.add(e));

      return Expanded(child: ListView(children: children));
    }
  }
}

abstract class _ArchipelabuttSetting<T> extends FormField {
  const _ArchipelabuttSetting({super.key, required super.builder});
}
