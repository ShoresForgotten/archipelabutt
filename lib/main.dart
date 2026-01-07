import 'dart:math';

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
  runApp(const ArchipelabuttApp());
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
        actions: [
          // TODO: Add buttplug & archipelago connection widgets
          IconButton(
            icon: const Icon(Icons.power),
            tooltip: 'Buttplug Connection',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ButtplugConnection>(
                  builder: (context) => ButtplugConnectionSettingsPage(),
                ),
              ).then((value) {
                if (value != null) state.bpConn = value;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Archipelago Connection',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ArchipelagoConnection>(
                  //TODO: UUID generation
                  builder:
                      (context) => ArchipelagoConnectionSettingsPage(
                        uuid: 'placeholder',
                      ),
                ),
              ).then((value) {
                if (value != null) state.apConn = value;
              });
            },
          ),
        ],
      ),
      body: ChangeNotifierProvider<DeviceManager>(
        create: (ctx) => DeviceManager(),
        child: ButtplugSettings(),
      ),
    );
  }
}
