import 'package:archipelabutt/state/buttplug_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ButtplugSettingsPage extends StatelessWidget {
  const ButtplugSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ButtplugConnection>(
      builder: (context, connection, child) {
        return ButtplugConnectionSettingsArea();
      },
    );
  }
}

class ButtplugConnectionSettingsArea extends StatefulWidget {
  const ButtplugConnectionSettingsArea({super.key});

  @override
  State<ButtplugConnectionSettingsArea> createState() =>
      _ButtplugConnectionSettingsAreaState();
}

class _ButtplugConnectionSettingsAreaState
    extends State<ButtplugConnectionSettingsArea> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<ButtplugConnection>(
      builder: (context, state, child) {
        _hostController.text = state.host;
        _portController.text = state.port.toString();
        return Expanded(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(label: Text('Host')),
                  controller: _hostController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Host cannot be empty.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(label: Text('Port')),
                  controller: _portController,
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
                ),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          state.host = _hostController.text;
                          state.port = int.parse(_portController.text);
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
          ),
        );
      },
    );
  }
}
