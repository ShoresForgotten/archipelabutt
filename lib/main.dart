import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/state.dart';
import 'state/device/device_manager.dart';
import 'state/archipelago_connection.dart';
import 'state/buttplug_connection.dart';

import 'archipelago_connection_settings.dart';
import 'buttplug_connection_settings.dart';
import 'buttplug_device_settings.dart';

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
  final ArchipelabuttState state = ArchipelabuttState('Bingus');

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
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        alignment: Alignment.center,
        child: ChangeNotifierProvider<DeviceManager>(
          create: (ctx) => DeviceManager(),
          child: ButtplugSettings(),
        ),
      ),
    );
  }
}
