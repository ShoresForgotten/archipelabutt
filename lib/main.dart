import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/state.dart';
import 'state/archipelabutt_device.dart';
import 'state/archipelago_connection.dart';
import 'state/buttplug_connection.dart';

import 'archipelago_connection_settings.dart';
import 'buttplug_connection_settings.dart';
import 'buttplug_device_settings.dart';
import 'archipelago_text_client.dart';

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
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Archipelago Log', icon: Icon(Icons.chat_bubble)),
              Tab(text: 'Device Settings', icon: Icon(Icons.settings)),
              Tab(
                text: 'Archipelago Connection',
                icon: Icon(Icons.question_mark),
              ),
              Tab(text: 'Buttplug Connection', icon: Icon(Icons.question_mark)),
              Tab(text: 'License Information', icon: Icon(Icons.pages)),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Container(
          margin: EdgeInsets.all(8),
          alignment: Alignment.center,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<ArchipelabuttDeviceIndex>(
                create: (_) => state.bpDevices,
              ),
              ChangeNotifierProvider<ArchipelagoConnection>(
                create: (_) => state.apConn,
              ),
              ChangeNotifierProvider<ButtplugConnection>(
                create: (_) => state.bpConn,
              ),
              ChangeNotifierProvider<MessageList>(
                create: (_) => state.apConn.displayMessages,
              ),
            ],
            child: const TabBarView(
              children: [
                ArchipelagoTextClient(),
                ButtplugDeviceSettings(),
                ArchipelagoConnectionSettings(),
                ButtplugConnectionSettings(),
                LicensePage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
