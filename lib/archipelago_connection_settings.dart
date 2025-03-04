import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'state/archipelago_connection.dart';

class ArchipelagoConnectionSettingsArea extends StatefulWidget {
  const ArchipelagoConnectionSettingsArea({super.key});

  @override
  State<ArchipelagoConnectionSettingsArea> createState() =>
      _ArchipelagoConnectionSettingsAreaState();
}

class _ArchipelagoConnectionSettingsAreaState
    extends State<ArchipelagoConnectionSettingsArea> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<ArchipelagoConnection>(
        builder: (context, state, child) {
          _hostController.text = state.host;
          _portController.text = state.port.toString();
          _nameController.text = state.name;
          _passwordController.text = state.password;
          return Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(label: Text('Host')),
                  controller: _hostController,
                  validator: (String? value) {
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
                ),
                TextFormField(
                  decoration: InputDecoration(label: Text('Name')),
                  controller: _nameController,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Name cannot be empty';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(label: Text('Password')),
                  controller: _passwordController,
                ),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          state.host = _hostController.text;
                          state.port = int.parse(_portController.text);
                          state.name = _nameController.text;
                          state.password = _passwordController.text;
                          state.connect();
                        }
                      },
                      child: Text('Connect'),
                    ),
                    OutlinedButton(onPressed: () {}, child: Text('Disconnect')),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
