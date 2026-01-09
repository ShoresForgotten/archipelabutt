import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'state/archipelago_connection.dart';

class _ArchipelagoConnectionForm extends StatefulWidget {
  const _ArchipelagoConnectionForm({
    super.key,
    this.defaultHost = '',
    this.defaultPort = 38281,
    this.defaultName = '',
    this.defaultPassword = '',
    required this.uuid,
  });

  final String defaultHost;
  final int defaultPort;
  final String defaultName;
  final String defaultPassword;
  final String uuid;

  @override
  State<_ArchipelagoConnectionForm> createState() =>
      _ArchipelagoConnectionFormState();
}

class _ArchipelagoConnectionFormState
    extends State<_ArchipelagoConnectionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String host;
  late int port;
  late String name;
  late String password;
  bool connecting = false;

  @override
  Widget build(BuildContext context) {
    if (connecting) {
      return CircularProgressIndicator(); //TODO: Better loading indicator
    } else {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: TextFormField(
                    decoration: InputDecoration(label: Text('Host')),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Host cannot be empty.';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      host = newValue!;
                    },
                    initialValue: widget.defaultHost,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: TextFormField(
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
                      port = int.parse(newValue!);
                    },
                    initialValue: widget.defaultPort.toString(),
                  ),
                ),
              ],
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
                name = newValue!;
              },
              initialValue: widget.defaultName,
            ),
            TextFormField(
              decoration: InputDecoration(label: Text('Password')),
              onSaved: (newValue) {
                if (newValue != null) {
                  password = newValue;
                }
              },
              initialValue: widget.defaultPassword,
            ),
            Row(
              children: [
                FilledButton(
                  onPressed:
                  // TODO: Add state-based availability
                  () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final apConn = ArchipelagoConnection.connect(
                        host: host,
                        port: port,
                        name: name,
                        password: password == '' ? null : password,
                        uuid: widget.uuid,
                      );
                      connecting = true;
                      apConn.then(
                        (result) {
                          if (context.mounted) {
                            Navigator.pop(context, result);
                          }
                        },
                        onError: (_) => connecting = false,
                      ); //TODO: Error handling
                    }
                  },
                  child: Text('Connect'),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}

class ArchipelagoConnectionSettingsPage extends StatelessWidget {
  const ArchipelagoConnectionSettingsPage({super.key, required this.uuid});

  final String uuid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archipelago Connection Settings')),
      // TODO: reload previous settings
      body: _ArchipelagoConnectionForm(uuid: uuid),
    );
  }
}
