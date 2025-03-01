import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'archipelago/archipelago.dart';

class ArchipelagoMessageLog extends StatelessWidget {
  final List<DisplayMessage> messages;
  const ArchipelagoMessageLog({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return ArchipelagoMessage(message: messages[index]);
      },
    );
  }
}

class MessageList extends ChangeNotifier {
  final List<DisplayMessage> _messages;
  List<DisplayMessage> get messages => UnmodifiableListView(_messages);

  MessageList(this._messages);

  void addMessage(DisplayMessage message) {
    _messages.add(message);
    notifyListeners();
  }
}

class ArchipelagoMessage extends StatelessWidget {
  final DisplayMessage message;

  const ArchipelagoMessage({super.key, required this.message});
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
