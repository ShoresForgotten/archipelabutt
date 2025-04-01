import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'state/archipelago_connection.dart';

class ArchipelagoConnectionSettings extends StatefulWidget {
  const ArchipelagoConnectionSettings({super.key});

  @override
  State<ArchipelagoConnectionSettings> createState() =>
      _ArchipelagoConnectionSettingsState();
}

class _ArchipelagoConnectionSettingsState
    extends State<ArchipelagoConnectionSettings> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ArchipelagoConnection>(
      builder: (context, state, child) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(label: Text('Host')),
                validator: (String? value) {
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
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Port cannot be empty';
                  }
                  final intValue = int.parse(value);
                  if (intValue <= 0 || intValue > 65535) {
                    return 'Invalid port';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  state.port = int.parse(newValue!);
                },
                initialValue: state.port.toString(),
              ),
              TextFormField(
                decoration: InputDecoration(label: Text('Name')),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Name cannot be empty';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  state.name = newValue!;
                },
                initialValue: state.name,
              ),
              TextFormField(
                decoration: InputDecoration(label: Text('Password')),
                onSaved: (newValue) {
                  if (newValue != null) {
                    state.password = newValue;
                  }
                },
              ),
              Row(
                children: [
                  FilledButton(
                    onPressed:
                    // TODO: Add state-based availability
                    () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        state.connect();
                      }
                    },
                    child: Text('Connect'),
                  ),
                  //OutlinedButton(onPressed: state.connected ? () {state.disconnect()} : null, child: Text('Disconnect')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
