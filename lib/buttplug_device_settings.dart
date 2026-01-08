import 'package:archipelabutt/state/device/device_controller.dart';
import 'package:archipelabutt/state/device/device_manager.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  DeviceController? _selectedDevice;

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceManager>(
      builder: (context, value, child) {
        if (!value.devices.containsValue(_selectedDevice)) {
          _selectedDevice = null;
        }
        List<ListTile> deviceTiles =
            value.devices.entries.sortedBy((x) => x.key).map((entry) {
              return ListTile(
                title: Text(entry.value.name),
                onTap: () => setState(() => _selectedDevice = entry.value),
                selected: _selectedDevice == entry.value,
              );
            }).toList();
        // TODO: Make this work for portrait aspect ratios
        return Row(
          children: [
            Expanded(child: ListView(children: deviceTiles)),
            Expanded(
              child:
                  _selectedDevice != null
                      ? _ButtplugDeviceSettings(device: _selectedDevice!)
                      : Text('No device selected'),
            ),
          ],
        );
      },
    );
  }
}

class _ButtplugDeviceSettings extends StatefulWidget {
  final DeviceController device;
  const _ButtplugDeviceSettings({super.key, required this.device});

  @override
  State<_ButtplugDeviceSettings> createState() =>
      _ButtplugDeviceSettingsState();
}

class _ButtplugDeviceSettingsState extends State<_ButtplugDeviceSettings> {
  late ScalarFeatureController selectedFeature;
  final List<ButtonSegment<ScalarFeatureController>> buttons = [];

  @override
  void initState() {
    selectedFeature = widget.device.features.first;
    for (final feature in widget.device.features) {
      buttons.add(
        ButtonSegment(value: feature, label: Text(feature.featureDescriptor)),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        _ButtplugFeatureSettings(selectedFeature),
      ],
    );
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
    return Column(children: settings);
  }
}

class _ButtplugScalarFeatureSetting extends StatefulWidget {
  final ScalarActivationInfo info;
  final String triggerName;
  final int stepCount;

  _ButtplugScalarFeatureSetting({
    super.key,
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
    return Column(
      children: [
        Row(
          children: [
            Text(widget.triggerName),
            TextField(
              controller: _durationController,
              onChanged: (value) {
                final tryParse = double.tryParse(value);
                if (tryParse != null) {
                  setState(
                    () => widget.info.duration = (tryParse * 1000).toInt(),
                  );
                }
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(r'[0-9]+\.?[0-9]*'),
                FilteringTextInputFormatter.singleLineFormatter,
              ],
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
    );
  }
}
