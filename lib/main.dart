import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'archipelago_connection_settings.dart';
import 'buttplug_connection_settings.dart';
import 'buttplug_device_settings.dart';
import 'state/archipelago_connection.dart';
import 'state/buttplug_connection.dart';
import 'state/state.dart';
import 'state/device/device_manager.dart';

void main() {
  runApp(
    ChangeNotifierProvider<ArchipelabuttState>(
      create: (context) => ArchipelabuttState(),
      builder: (context, child) => ArchipelabuttApp(),
    ),
  );
}

class ArchipelabuttApp extends StatelessWidget {
  const ArchipelabuttApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArchipelaButt',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(title: 'Archipelabutt'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ArchipelabuttState state = ArchipelabuttState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
        ), // TODO: Maybe make this access the license information?
        actions: [ButtplugConnectionButton(), ArchipelagoConnectionButton()],
      ),
      body: ChangeNotifierProvider<DeviceManager>.value(
        value:
            Provider.of<ArchipelabuttState>(context, listen: false).bpDevices,
        child: ButtplugSettings(),
      ),
    );
  }
}

class ButtplugConnectionButton extends StatelessWidget {
  const ButtplugConnectionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon:
          Provider.of<ArchipelabuttState>(context, listen: true).bpConnected
              ? const Icon(Icons.power)
              : const Icon(Icons.power), //TODO: Connected & Disconnected icons
      tooltip: 'Buttplug Connection',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute<ButtplugConnection>(
            builder: (context) => ButtplugConnectionSettingsPage(),
          ),
        ).then((value) {
          if (value != null && context.mounted) {
            Provider.of<ArchipelabuttState>(context, listen: false).bpConn =
                value;
          }
        });
      },
    );
  }
}

class ArchipelagoConnectionButton extends StatelessWidget {
  const ArchipelagoConnectionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon:
          Provider.of<ArchipelabuttState>(context, listen: true).apConnected
              ? const Icon(Icons.people)
              : const Icon(Icons.people), //TODO: Connected & Disconnected icons
      tooltip: 'Archipelago Connection',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute<ArchipelagoConnection>(
            //TODO: UUID generation
            builder:
                (context) =>
                    ArchipelagoConnectionSettingsPage(uuid: 'placeholder'),
          ),
        ).then((value) {
          if (value != null && context.mounted) {
            Provider.of<ArchipelabuttState>(context, listen: false).apConn =
                value;
          }
        });
      },
    );
  }
}
