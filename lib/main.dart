import 'package:archipelabutt/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const ArchipelabuttApp());
}

class ArchipelabuttApp extends StatelessWidget {
  const ArchipelabuttApp({super.key});

  // This widget is the root of your application.
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class AppPage {
  final String name;
  final Widget icon;
  final Widget body;

  const AppPage(this.name, this.icon, this.body);
}

const List<AppPage> pages = [
  AppPage('Archipelago Log', Icon(Icons.chat_bubble), Placeholder()),
  AppPage(
    'Intensity Settings',
    Icon(Icons.settings),
    ButtplugIntensitySettingsArea(),
  ),
  AppPage('Archipelago Connection', Icon(Icons.question_mark), Placeholder()),
  AppPage(
    'Buttplug Connection',
    Icon(Icons.question_mark),
    ButtplugConnectionSettingsArea(),
  ),
];

class _HomePageState extends State<HomePage> {
  final ButtplugConnection _bpConn = ButtplugConnection();
  final ArchipelagoConnection _apConn = ArchipelagoConnection();
  int screenIndex = 0;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
            ChangeNotifierProvider<ButtplugConnection>(
              create: (_) => ButtplugConnection(),
            ),
            ChangeNotifierProvider<ButtplugIntensitySettings>(
              create: (_) => ButtplugIntensitySettings(),
            ),
          ],
          child: pages[screenIndex].body,
        ),
      ),
    );
  }
}

class ButtplugSettingsPage extends StatelessWidget {
  const ButtplugSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ButtplugConnection>(
      builder: (context, connection, child) {
        if (!connection.connected) {
          return ButtplugConnectionSettingsArea();
        }
        return ButtplugIntensitySettingsArea();
      },
    );
  }
}

class ButtplugConnectionSettingsArea extends StatelessWidget {
  const ButtplugConnectionSettingsArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ButtplugConnection>(
      builder: (context, connection, child) {
        return SizedBox(
          width: 500,
          child: Column(
            children: [
              TextField(
                onChanged: (value) => connection.host = value,
                decoration: InputDecoration(label: Text('Host')),
                controller: TextEditingController(text: connection.host),
              ),
              TextField(
                onChanged: (value) => connection.port = int.parse(value),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(label: Text('Port')),
                controller: TextEditingController(
                  text: connection.port.toString(),
                ),
              ),
              FilledButton(
                onPressed: () => connection.connect(),
                child: Text('Connect'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ButtplugIntensitySettingsArea extends StatelessWidget {
  const ButtplugIntensitySettingsArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ButtplugIntensitySettings>(
      builder: (context, settings, child) {
        return SizedBox(
          width: 500,
          child: Column(
            children: [
              RangeSlider(
                labels: RangeLabels('Minimum Intensity', 'Maximum Intensity'),
                values: RangeValues(
                  settings.minIntensity,
                  settings.maxIntensity,
                ),
                onChanged: (value) {
                  settings.minIntensity = value.start;
                  settings.maxIntensity = value.end;
                },
                min: 0,
                max: 100,
              ),
              TextField(
                onChanged:
                    (value) =>
                        settings.boringCheckValue = double.tryParse(value) ?? 0,
                decoration: InputDecoration(label: Text('Boring')),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^-?[0-9]*\.?[0-9]*'),
                  ),
                ],
              ),
              TextField(
                onChanged:
                    (value) =>
                        settings.logicalAdvancementCheckValue =
                            double.tryParse(value) ?? 0,
                decoration: InputDecoration(label: Text('Logical Advancement')),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^-?[0-9]*\.?[0-9]*'),
                  ),
                ],
              ),
              TextField(
                onChanged:
                    (value) =>
                        settings.usefulCheckValue = double.tryParse(value) ?? 0,
                decoration: InputDecoration(label: Text('Useful')),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^-?[0-9]*\.?[0-9]*'),
                  ),
                ],
              ),
              TextField(
                onChanged:
                    (value) =>
                        settings.trapCheckValue = double.tryParse(value) ?? 0,
                decoration: InputDecoration(label: Text('Trap')),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^-?[0-9]*\.?[0-9]*'),
                  ),
                ],
              ),
              TextField(
                onChanged:
                    (value) => settings.decayRate = double.tryParse(value) ?? 0,
                decoration: InputDecoration(label: Text('Decay Rate')),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^-?[0-9]*\.?[0-9]*'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
