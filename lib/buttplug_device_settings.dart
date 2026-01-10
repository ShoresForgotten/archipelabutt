import 'dart:developer';

import 'package:archipelabutt/state/device/device_controller.dart';
import 'package:archipelabutt/state/device/device_manager.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ButtplugSettings extends StatefulWidget {
  const ButtplugSettings({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ButtplugSettingsState();
  }
}

class _ButtplugSettingsState extends State<ButtplugSettings> {
  DeviceController? _selectedDevice;

  @override
  Widget build(BuildContext context) {
    List<ListTile> deviceTiles =
        Provider.of<DeviceManager>(context).devices.values.map((entry) {
          return ListTile(
            title: Text(entry.displayName ?? entry.name),
            onTap: () {
              setState(() => _selectedDevice = entry);
            },
            selected: _selectedDevice == entry,
          );
        }).toList();
    // TODO: Make this work for portrait aspect ratios
    return Row(
      children: [
        Expanded(flex: 1, child: ListView(children: deviceTiles)),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: _SelectedDeviceSettings(device: _selectedDevice),
          ),
        ),
      ],
    );
  }
}

class _SelectedDeviceSettings extends StatelessWidget {
  final DeviceController? _device;

  const _SelectedDeviceSettings({device}) : _device = device;

  @override
  Widget build(BuildContext context) {
    if (_device != null &&
        Provider.of<DeviceManager>(context).devices.containsValue(_device)) {
      return _ButtplugDeviceSettings(device: _device, key: ObjectKey(_device));
    } else {
      return Center(child: Text('No device selected'));
    }
  }
}

class _ButtplugDeviceSettings extends StatefulWidget {
  final DeviceController device;
  const _ButtplugDeviceSettings({super.key, required this.device});

  @override
  State<_ButtplugDeviceSettings> createState() {
    return _ButtplugDeviceSettingsState();
  }
}

class _ButtplugDeviceSettingsState extends State<_ButtplugDeviceSettings> {
  ScalarFeatureController? selectedFeature;
  final List<ButtonSegment<ScalarFeatureController>> buttons = [];

  @override
  void initState() {
    selectedFeature = widget.device.features.elementAtOrNull(0);
    for (final feature in widget.device.features) {
      buttons.add(
        ButtonSegment(value: feature, label: Text(feature.featureDescriptor)),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (buttons.isEmpty) {
      return Center(
        child: Text(
          "No supported features. Strokers aren't currently supported.",
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
        child: Column(
          spacing: 8.0,
          children: [
            SegmentedButton(
              segments: const <ButtonSegment<CheckOption>>[
                ButtonSegment<CheckOption>(
                  value: CheckOption.sent,
                  label: Text('Sent'),
                  icon: Icon(Icons.output),
                ),
                ButtonSegment<CheckOption>(
                  value: CheckOption.received,
                  label: Text('Received'),
                  icon: Icon(Icons.input),
                ),
                ButtonSegment<CheckOption>(
                  value: CheckOption.disabled,
                  label: Text('Disabled'),
                  icon: Icon(Icons.play_disabled),
                ),
              ],
              selected: <CheckOption>{widget.device.activateOn},
              onSelectionChanged:
                  (p0) => setState(() => widget.device.activateOn = p0.first),
            ),
            Divider(),
            SegmentedButton(
              segments: buttons,
              selected: {selectedFeature},
              onSelectionChanged:
                  (p0) => setState(() => selectedFeature = p0.first),
            ),
            Divider(),
            _ButtplugFeatureSettings(selectedFeature!),
          ],
        ),
      );
    }
  }
}

class _ButtplugFeatureSettings extends StatelessWidget {
  final ScalarFeatureController feature;
  final List<Widget> settings = [];

  _ButtplugFeatureSettings(this.feature) {
    for (final setting in feature.activationInfo.entries.sortedBy(
      (x) => x.key.index,
    )) {
      settings.add(
        _ButtplugScalarFeatureSetting(
          info: setting.value,
          triggerName: setting.key.name,
          stepCount: feature.steps,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Expanded(child: ListView(children: settings));
  }
}

class _ButtplugScalarFeatureSetting extends StatefulWidget {
  final ScalarActivationInfo info;
  final String triggerName;
  final int stepCount;
  final RegExp regex = RegExp(r'^[0-9]+\.?[0-9]*$');

  _ButtplugScalarFeatureSetting({
    required this.info,
    required this.triggerName,
    required this.stepCount,
  });

  @override
  State<StatefulWidget> createState() => _ButtplugScalarFeatureSettingState();
}

class _ButtplugScalarFeatureSettingState
    extends State<_ButtplugScalarFeatureSetting> {
  late final TextEditingController _durationController;

  @override
  void initState() {
    _durationController = TextEditingController.fromValue(
      TextEditingValue(
        text: (widget.info.duration.toDouble() / 1000).toString(),
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        spacing: 4.0,
        children: [
          Row(
            children: [
              Flexible(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.triggerName),
                ),
              ),
              Flexible(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextField(
                    controller: _durationController,
                    decoration: InputDecoration(
                      hintText: 'Duration (in seconds)',
                    ),
                    // TODO: update value on focus change
                    onSubmitted: (value) {
                      final tryParse = double.tryParse(value);
                      if (tryParse != null) {
                        setState(() {
                          widget.info.duration = (tryParse * 1000).toInt();
                          _durationController.text =
                              (widget.info.duration.toDouble() / 1000)
                                  .toString();
                        });
                      }
                    },

                    inputFormatters: [
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        if (widget.regex.hasMatch(newValue.text) ||
                            newValue.text == '') {
                          return newValue;
                        } else {
                          return oldValue;
                        }
                      }),
                      FilteringTextInputFormatter.singleLineFormatter,
                    ],
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: widget.info.intensity,
            onChanged: (x) => setState(() => widget.info.intensity = x),
            min: 0.0,
            max: 1.0,
            divisions: widget.stepCount,
          ),
        ],
      ),
    );
  }
}
