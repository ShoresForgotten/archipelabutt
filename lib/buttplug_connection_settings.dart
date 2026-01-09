import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'state/buttplug_connection.dart';

class _ButtplugConnectionForm extends StatefulWidget {
  const _ButtplugConnectionForm({
    this.defaultHost = 'localhost',
    this.defaultPort = 12345,
  });

  final String defaultHost;
  final int defaultPort;

  @override
  State<_ButtplugConnectionForm> createState() =>
      _ButtplugConnectionFormState();
}

class _ButtplugConnectionFormState extends State<_ButtplugConnectionForm> {
  // These shouldn't be accessed before form save
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String host;
  late int port;
  bool connecting = false;

  @override
  Widget build(BuildContext context) {
    if (connecting) {
      return Center(
        child: CircularProgressIndicator(),
      ); //TODO: Better loading indicator
    } else {
      // TODO: This shifts on validation rejection
      return Form(
        key: _formKey,
        child: Column(
          spacing: 8.0,
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
                host = newValue ?? '';
              },
              initialValue: widget.defaultHost,
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
              initialValue: widget.defaultPort.toString(),
              onSaved: (newValue) {
                port = int.parse(newValue!);
              },
            ),
            FilledButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  final bpConn = ButtplugConnection.connect(
                    host: host,
                    port: port,
                  );
                  connecting = true;
                  bpConn.then((result) {
                    if (context.mounted) {
                      Navigator.pop(context, result);
                    }
                  }, onError: (_) => connecting = false); //TODO: Error handling
                }
              },
              child: Text('Connect'),
            ),
          ],
        ),
      );
    }
  }
}

class ButtplugConnectionSettingsPage extends StatelessWidget {
  const ButtplugConnectionSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buttplug Connection Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      //TODO: Load previous settings
      body: Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.topCenter,
        child: SizedBox(width: 700.0, child: _ButtplugConnectionForm()),
      ),
    );
  }
}
