import 'package:archipelabutt/state.dart';
import 'package:buttplug/buttplug.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'archipelago/archipelago.dart';
import 'archipelago_text_client.dart';

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
  AppPage('Archipelago Log', Icon(Icons.chat_bubble), ArchipelagoLogArea()),
  AppPage('Intensity Settings', Icon(Icons.settings), ButtplugControllerArea()),
  AppPage(
    'Archipelago Connection',
    Icon(Icons.question_mark),
    ArchipelagoConnectionSettingsArea(),
  ),
  AppPage(
    'Buttplug Connection',
    Icon(Icons.question_mark),
    ButtplugConnectionSettingsArea(),
  ),
];

class _HomePageState extends State<HomePage> {
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
            ChangeNotifierProvider(create: (_) => ArchipelabuttState('bingus')),
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
        return ButtplugControllerArea();
      },
    );
  }
}

class ButtplugConnectionSettingsArea extends StatelessWidget {
  const ButtplugConnectionSettingsArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArchipelabuttState>(
      builder: (context, state, child) {
        return SizedBox(
          width: 500,
          child: Column(
            children: [
              TextField(
                onChanged: (value) => state.bpConn.host = value,
                decoration: InputDecoration(label: Text('Host')),
                controller: TextEditingController(text: state.bpConn.host),
              ),
              TextField(
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) {
                    state.bpConn.port = parsed;
                  }
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(label: Text('Port')),
                controller: TextEditingController(
                  text: state.bpConn.port.toString(),
                ),
              ),
              Row(
                children: [
                  FilledButton(
                    onPressed: () => state.bpConn.connect(),
                    child: Text('Connect'),
                  ),
                  FilledButton(
                    onPressed: () => state.bpConn.client?.startScanning(),
                    child: Text('Start scan'),
                  ),
                  FilledButton(
                    onPressed: () => state.bpConn.client?.stopScanning(),
                    child: Text('Stop scan'),
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

class ButtplugControllerArea extends StatefulWidget {
  const ButtplugControllerArea({super.key});

  @override
  State<ButtplugControllerArea> createState() => _ButtplugControllerAreaState();
}

class _ButtplugControllerAreaState extends State<ButtplugControllerArea> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ArchipelabuttState>(
      builder: (context, settings, child) {
        return SizedBox(width: 500, child: ButtplugDeviceSelector());
      },
    );
  }
}

class ButtplugDeviceSelector extends StatefulWidget {
  const ButtplugDeviceSelector({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ButtplugDeviceSelectorState();
  }
}

class _ButtplugDeviceSelectorState extends State<ButtplugDeviceSelector> {
  ArchipelabuttDevice? currentDeviceControllerSelection;

  @override
  Widget build(BuildContext context) {
    return Consumer<ArchipelabuttState>(
      builder: (context, value, child) {
        value.updateBpDevices();
        return Column(
          children: [
            Row(
              children: [
                DropdownMenu<ArchipelabuttDevice>(
                  dropdownMenuEntries:
                      value.bpDevices.devices.values
                          .map(
                            (x) => DropdownMenuEntry(
                              value: x,
                              label: x.controller.device.name,
                            ),
                          )
                          .toList(),
                  onSelected: (ArchipelabuttDevice? device) {
                    setState(() {
                      currentDeviceControllerSelection =
                          value.bpDevices.devices[device!
                              .controller
                              .device
                              .index];
                    });
                  },
                ),
                DropdownMenu<
                  ArchipelabuttDeviceController Function(ButtplugClientDevice)
                >(
                  dropdownMenuEntries:
                      ArchipelabuttDeviceController.options.keys
                          .map(
                            (k) => DropdownMenuEntry(
                              value: ArchipelabuttDeviceController.options[k]!,
                              label: k,
                            ),
                          )
                          .toList(),
                  initialSelection:
                      ArchipelabuttDeviceController
                          .options[currentDeviceControllerSelection
                          ?.controller
                          .cName],
                  onSelected: (value) {
                    if (value != null) {
                      currentDeviceControllerSelection?.controller = value(
                        currentDeviceControllerSelection!.controller.device,
                      );
                      setState(() {});
                    }
                  },
                ),
                DropdownMenu<ArchipelabuttCommandStrategy Function()>(
                  dropdownMenuEntries:
                      ArchipelabuttCommandStrategy.options.keys
                          .map(
                            (e) => DropdownMenuEntry(
                              value: ArchipelabuttCommandStrategy.options[e]!,
                              label: e,
                            ),
                          )
                          .toList(),
                  initialSelection:
                      ArchipelabuttCommandStrategy
                          .options[currentDeviceControllerSelection
                          ?.strategy
                          .strategyName],
                  onSelected: (value) {
                    if (value != null) {
                      currentDeviceControllerSelection?.strategy = value();
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
            Divider(),
            ButtplugControllerSettingsArea(
              device: currentDeviceControllerSelection,
            ),
          ],
        );
      },
    );
  }
}

class ButtplugControllerSettingsArea extends StatelessWidget {
  final ArchipelabuttDevice? device;
  const ButtplugControllerSettingsArea({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    if (device == null) {
      return Text('No device selected');
    } else {
      List<Widget> children = [];
      device!.controller.settings
          .map((e) => Placeholder())
          .forEach((element) => children.add(element));
      children.add(Divider());
      device!.strategy.settings
          .map((e) {
            if (e is ArchipelabuttDoubleSetting) {
              return TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp('^-?[0-9]*\.?[0-9]*'),
                  ),
                ],
                controller: TextEditingController(text: e.value.toString()),
                decoration: InputDecoration(label: Text(e.label)),
                onChanged: (value) {
                  final newValue = double.tryParse(value);
                  if (newValue != null) {
                    e.value = newValue;
                  }
                },
              );
            } else if (e is ArchipelabuttUserSetting<Player>) {
              return TextField(
                maxLength: 16,
                controller: TextEditingController(text: e.value.name),
                decoration: InputDecoration(label: Text(e.label)),
                onChanged: (value) {
                  e.value = Player(value);
                },
              );
            }
            return Placeholder();
          })
          .forEach((e) => children.add(e));

      return Expanded(child: ListView(children: children));
    }
  }
}

class ArchipelagoConnectionSettingsArea extends StatelessWidget {
  const ArchipelagoConnectionSettingsArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArchipelabuttState>(
      builder: (context, state, child) {
        return SizedBox(
          width: 500,
          child: Column(
            children: [
              TextField(
                onChanged: (value) => state.apConn.host = value,
                decoration: InputDecoration(label: Text('Host')),
                controller: TextEditingController(text: state.apConn.host),
              ),
              TextField(
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) {
                    state.apConn.port = parsed;
                  }
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(label: Text('Port')),
                controller: TextEditingController(
                  text: state.apConn.port.toString(),
                ),
              ),
              TextField(
                onChanged: (value) => state.apConn.name = value,
                decoration: InputDecoration(label: Text('Name')),
                controller: TextEditingController(text: state.apConn.name),
              ),
              TextField(
                onChanged: (value) => state.apConn.password = value,
                decoration: InputDecoration(label: Text('Password')),
                controller: TextEditingController(text: state.apConn.password),
              ),
              FilledButton(
                onPressed: () => state.apConn.connect(),
                child: Text('Connect'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ArchipelagoLogArea extends StatelessWidget {
  const ArchipelagoLogArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArchipelabuttState>(
      builder: (BuildContext context, ArchipelabuttState value, Widget? child) {
        return ArchipelagoMessageLog(
          messages: value.apDisplayMessages.messages,
        );
      },
    );
  }
}
