import 'package:archipelabutt/state/archipelabutt_device.dart';
import 'package:archipelabutt/state/state.dart';
import 'package:buttplug/buttplug.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'archipelago/archipelago.dart';

class ButtplugDeviceSelector extends StatefulWidget {
  const ButtplugDeviceSelector({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ButtplugDeviceSelectorState();
  }
}

class _ButtplugDeviceSelectorState extends State<ButtplugDeviceSelector> {
  TextEditingController deviceSelectionController = TextEditingController();
  GlobalKey<FormState> _deviceSelectionKey = GlobalKey();
  ArchipelabuttDevice? currentDeviceControllerSelection;

  @override
  Widget build(BuildContext context) {
    return Consumer<ArchipelabuttDeviceIndex>(
      builder: (context, value, child) {
        deviceSelectionController.text =
            currentDeviceControllerSelection?.name ?? '';
        return Column(
          children: [
            Row(
              children: [
                DropdownMenu<ArchipelabuttDevice>(
                  controller: deviceSelectionController,
                  dropdownMenuEntries:
                      value.devices.values
                          .map(
                            (x) => DropdownMenuEntry(value: x, label: x.name),
                          )
                          .toList(),
                  onSelected: (ArchipelabuttDevice? device) {
                    setState(() {
                      currentDeviceControllerSelection = device;
                    });
                  },
                ),
                DropdownMenu<
                  ArchipelabuttDeviceController Function(ButtplugClientDevice)
                >(
                  dropdownMenuEntries:
                      ArchipelabuttDeviceController.options.keys
                          .map(
                            (k) => DropdownMenuEntry(
                              value: ArchipelabuttDeviceController.options[k]!,
                              label: k,
                            ),
                          )
                          .toList(),
                  initialSelection:
                      ArchipelabuttDeviceController
                          .options[currentDeviceControllerSelection
                          ?.controller
                          .cName],
                  onSelected: (value) {
                    if (value != null) {
                      currentDeviceControllerSelection?.controller = value(
                        currentDeviceControllerSelection!.controller.device,
                      );
                      setState(() {});
                    }
                  },
                ),
                DropdownMenu<ArchipelabuttCommandStrategy Function()>(
                  dropdownMenuEntries:
                      ArchipelabuttCommandStrategy.options.keys
                          .map(
                            (e) => DropdownMenuEntry(
                              value: ArchipelabuttCommandStrategy.options[e]!,
                              label: e,
                            ),
                          )
                          .toList(),
                  initialSelection:
                      ArchipelabuttCommandStrategy
                          .options[currentDeviceControllerSelection
                          ?.strategy
                          .strategyName],
                  onSelected: (value) {
                    if (value != null) {
                      currentDeviceControllerSelection?.strategy = value();
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
            Divider(),
            ButtplugControllerSettingsArea(
              device: currentDeviceControllerSelection,
            ),
          ],
        );
      },
    );
  }
}

class ButtplugControllerSettingsArea extends StatelessWidget {
  final ArchipelabuttDevice? device;
  const ButtplugControllerSettingsArea({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    if (device == null) {
      return Text('No device selected');
    } else {
      List<Widget> children = [];
      device.settings
          .map((e) => Placeholder())
          .forEach((element) => children.add(element));
      children.add(Divider());
      device!.strategy.settings
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
