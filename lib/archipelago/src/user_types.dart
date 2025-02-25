library;

import 'protocol_types.dart';
import 'server_to_client.dart';

sealed class ArchipelagoEvent {}

class RoomUpdate extends ArchipelagoEvent {
  final RoomUpdateMessage update;

  RoomUpdate(this.update);
}

class ItemsReceived extends ArchipelagoEvent {
  final List<ItemLocation> items;
  final int nextEmptySlot;

  ItemsReceived(this.items, this.nextEmptySlot);
}

class LocationsScouted extends ArchipelagoEvent {
  final List<ItemLocation> scouts;

  LocationsScouted(this.scouts);
}

class DisplayMessage extends ArchipelagoEvent {
  final List<MessagePart> parts;

  DisplayMessage(this.parts);
}

class Bounced extends ArchipelagoEvent {
  final List<String>? games;
  final List<Player>? players;
  final List<String>? tags;
  final Map<dynamic, dynamic> data;

  Bounced({required this.data, this.games, this.players, this.tags});
}

class InvalidPacket extends ArchipelagoEvent {
  final String type;
  final String? originalCommand;
  final String text;

  InvalidPacket(this.type, this.text, [this.originalCommand]);
}

class DataRetrieved extends ArchipelagoEvent {
  final Map<String, dynamic> data;

  DataRetrieved(this.data);
}

class SetDataReply extends ArchipelagoEvent {
  final String key;
  final dynamic value;
  final dynamic originalValue;
  final int slot;

  SetDataReply(this.key, this.value, this.originalValue, this.slot);
}

sealed class MessagePart {
  String get text;

  const MessagePart();
}

class TextMessagePart extends MessagePart {
  @override
  final String text;

  const TextMessagePart(this.text);
}

class PlayerMessagePart extends MessagePart {
  final Player player;
  @override
  String get text => player.name;
  const PlayerMessagePart(this.player);
}

class ItemMessagePart extends MessagePart {
  final Item item;
  @override
  String get text => item.name;

  const ItemMessagePart(this.item);
}

class LocationMessagePart extends MessagePart {
  final Location location;
  @override
  String get text => location.name;

  const LocationMessagePart(this.location);
}

class EntranceMessagePart extends MessagePart {
  final Entrance entrance;
  @override
  String get text => entrance.name;

  const EntranceMessagePart(this.entrance);
}

class HintStatusPart extends MessagePart {
  @override
  final String text;
  final HintStatus status;

  const HintStatusPart(this.text, this.status);
}

class ColorMessagePart extends MessagePart {
  @override
  final String text;
  final ConsoleColor color;

  const ColorMessagePart(this.text, this.color);
}

class Player {
  final String name;
  final int? id;
  const Player(this.name, [this.id]);
}

class Item {
  final String name;
  final int id;
  final bool logicalAdvancement;
  final bool useful;
  final bool trap;
  const Item(
    this.name,
    this.id,
    this.logicalAdvancement,
    this.useful,
    this.trap,
  );
}

class Location {
  final String name;
  final int id;
  const Location(this.name, this.id);
}

class Entrance {
  final String name;

  const Entrance(this.name);
}

class ItemLocation {
  final Location location;
  final Item item;

  const ItemLocation(this.location, this.item);
}
