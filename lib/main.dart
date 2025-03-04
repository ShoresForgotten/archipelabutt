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
  int screenIndex = 0;
  final ArchipelabuttState state = ArchipelabuttState('Bingus');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(
        selectedIndex: screenIndex,
        onDestinationSelected: (value) {
          setState(() {
            screenIndex = value;
          });
        },
        children:
            pages
                .map(
                  (e) => NavigationDrawerDestination(
                    icon: e.icon,
                    label: Text(e.name),
                  ),
                )
                .toList(),
      ),
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
          child: pages[screenIndex].body,
        ),
      ),
    );
  }
}

class AppPage {
  final String name;
  final Widget icon;
  final Widget body;

  const AppPage(this.name, this.icon, this.body);
}

const List<AppPage> pages = [
  AppPage('Archipelago Log', Icon(Icons.chat_bubble), ArchipelagoTextClient()),
  AppPage('Intensity Settings', Icon(Icons.settings), ButtplugDeviceSettings()),
  AppPage(
    'Archipelago Connection',
    Icon(Icons.question_mark),
    ArchipelagoConnectionSettings(),
  ),
  AppPage(
    'Buttplug Connection',
    Icon(Icons.question_mark),
    ButtplugConnectionSettings(),
  ),
];
