import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'state/buttplug_connection.dart';

class ButtplugConnectionSettings extends StatefulWidget {
  const ButtplugConnectionSettings({super.key});

  @override
  State<ButtplugConnectionSettings> createState() =>
      _ButtplugConnectionSettingsState();
}

class _ButtplugConnectionSettingsState
    extends State<ButtplugConnectionSettings> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ButtplugConnection>(
      builder: (context, state, child) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(label: Text('Host')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Host cannot be empty.';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  state.host = newValue!;
                },
                initialValue: state.host,
              ),
              TextFormField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(label: Text('Port')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Port cannot be empty.';
                  }
                  final intValue = int.parse(value);
                  if (intValue <= 0 || intValue > 65535) {
                    return 'Invalid port';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  final parsed = int.parse(newValue!);
                  state.port = parsed;
                },
                initialValue: state.port.toString(),
              ),
              Row(
                children: [
                  FilledButton(
                    onPressed:
                    // TODO: Add state-based availability
                    () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState!.save();
                        state.connect();
                      }
                    },
                    child: Text('Connect'),
                  ),
                  FilledButton(
                    onPressed: () => state.client?.startScanning(),
                    child: Text('Start scan'),
                  ),
                  FilledButton(
                    onPressed: () => state.client?.stopScanning(),
                    child: Text('Stop scan'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
