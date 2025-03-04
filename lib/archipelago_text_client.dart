import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:archipelago/archipelago.dart';
import 'state/archipelago_connection.dart';

class ArchipelagoTextClient extends StatelessWidget {
  const ArchipelagoTextClient({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArchipelagoConnection>(
      builder: (
        BuildContext context,
        ArchipelagoConnection value,
        Widget? child,
      ) {
        return Column(
          children: [
            Flexible(child: _ArchipelagoMessageLog()),
            Divider(),
            MessageField(),
          ],
        );
      },
    );
  }
}

class MessageField extends StatelessWidget {
  final TextEditingController _textEditingController = TextEditingController();
  MessageField({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArchipelagoConnection>(
      builder: (context, value, child) {
        return TextField(
          controller: _textEditingController,
          decoration: InputDecoration(hintText: 'Send a message'),
          onSubmitted: (message) {
            value.say(message);
            _textEditingController.text = '';
          },
        );
      },
    );
  }
}

class _ArchipelagoMessageLog extends StatelessWidget {
  const _ArchipelagoMessageLog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageList>(
      builder: (BuildContext context, MessageList value, Widget? child) {
        return ListView.builder(
          itemCount: value.messages.length,
          itemBuilder: (context, index) {
            return _ArchipelagoMessage(message: value.messages[index]);
          },
        );
      },
    );
  }
}

class _ArchipelagoMessage extends StatelessWidget {
  final DisplayMessage message;

  const _ArchipelagoMessage({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: message.parts.map((e) => e.toTextSpan()).toList(),
      ),
    );
  }
}

extension on MessagePart {
  TextSpan toTextSpan() {
    switch (this) {
      case TextMessagePart():
        return TextSpan(text: text);
      case PlayerMessagePart():
        return TextSpan(text: text, style: TextStyle(color: Colors.blue));
      case ItemMessagePart():
        var part = this as ItemMessagePart;
        Color? color;
        if (part.item.trap) {
          color = Colors.red;
        } else if (part.item.logicalAdvancement) {
          color = Colors.green;
        } else if (part.item.useful) {
          color = Colors.teal;
        }
        return TextSpan(
          text: text,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        );
      case LocationMessagePart():
        return TextSpan(text: text, style: TextStyle(color: Colors.teal));
      case EntranceMessagePart():
        return TextSpan(text: text, style: TextStyle(color: Colors.green));
      case HintStatusPart():
        var part = this as HintStatusPart;
        return TextSpan(text: text, style: part.status.style);
      case ColorMessagePart():
        var part = this as ColorMessagePart;
        return TextSpan(text: text, style: part.color.style);
    }
  }
}

extension on ConsoleColor {
  TextStyle get style {
    switch (this) {
      case ConsoleColor.bold:
        return TextStyle(fontWeight: FontWeight.bold);
      case ConsoleColor.underline:
        return TextStyle(decoration: TextDecoration.underline);
      case ConsoleColor.black:
        return TextStyle(color: Colors.black);
      case ConsoleColor.red:
        return TextStyle(color: Colors.red);
      case ConsoleColor.green:
        return TextStyle(color: Colors.green);
      case ConsoleColor.yellow:
        return TextStyle(color: Colors.yellow);
      case ConsoleColor.blue:
        return TextStyle(color: Colors.blue);
      case ConsoleColor.magenta:
        return TextStyle(color: Colors.purple);
      case ConsoleColor.cyan:
        return TextStyle(color: Colors.cyan);
      case ConsoleColor.white:
        return TextStyle(color: Colors.white);
      case ConsoleColor.blackBackground:
        return TextStyle(backgroundColor: Colors.black);
      case ConsoleColor.redBackground:
        return TextStyle(backgroundColor: Colors.red);
      case ConsoleColor.greenBackground:
        return TextStyle(backgroundColor: Colors.green);
      case ConsoleColor.yellowBackground:
        return TextStyle(backgroundColor: Colors.yellow);
      case ConsoleColor.blueBackground:
        return TextStyle(backgroundColor: Colors.blue);
      case ConsoleColor.magentaBackground:
        return TextStyle(backgroundColor: Colors.purple);
      case ConsoleColor.cyanBackground:
        return TextStyle(backgroundColor: Colors.cyan);
      case ConsoleColor.whiteBackground:
        return TextStyle(backgroundColor: Colors.white);
    }
  }
}

extension on HintStatus {
  TextStyle get style {
    switch (this) {
      case HintStatus.unspecified:
        return TextStyle();
      case HintStatus.noPriority:
        return TextStyle(color: Colors.grey);
      case HintStatus.avoid:
        return TextStyle(color: Colors.red);
      case HintStatus.priority:
        return TextStyle(color: Colors.yellow);
      case HintStatus.found:
        return TextStyle(color: Colors.green);
    }
  }
}
