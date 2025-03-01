library;

import 'protocol_types.dart';
import 'server_to_client.dart';

sealed class ArchipelagoEvent {}

class RoomUpdate extends ArchipelagoEvent {
  final RoomUpdateMessage update;

  RoomUpdate(this.update);
}

class ItemsReceived extends ArchipelagoEvent {
  final List<SentItem> items;
  final int nextEmptySlot;

  ItemsReceived(this.items, this.nextEmptySlot);
}

class LocationsScouted extends ArchipelagoEvent {
  /// [SentItem.player] refers to the receiving player here, rather than the sending player
  final List<SentItem> scouts;

  LocationsScouted(this.scouts);
}

class DisplayMessage extends ArchipelagoEvent {
  final List<MessagePart> parts;

  DisplayMessage(this.parts);
}

class ItemSend extends DisplayMessage {
  final Player receiving;
  final SentItem item;

  ItemSend(super.parts, this.receiving, this.item);
}

class ItemCheat extends DisplayMessage {
  final Player receiving;
  final SentItem item;

  ItemCheat(super.parts, this.receiving, this.item);
}

class HintMessage extends DisplayMessage {
  final Player receiving;
  final SentItem item;
  final bool found;

  HintMessage(super.parts, this.receiving, this.item, this.found);
}

class PlayerJoined extends DisplayMessage {
  final Player player;
  final List<String> tags;

  PlayerJoined(super.parts, this.player, this.tags);
}

class PlayerLeft extends DisplayMessage {
  final Player player;

  PlayerLeft(super.parts, this.player);
}

class ChatMessage extends DisplayMessage {
  final Player player;
  final String message;

  ChatMessage(super.parts, this.player, this.message);
}

class ServerChatMessage extends DisplayMessage {
  final String message;

  ServerChatMessage(super.parts, this.message);
}

class TutorialMessage extends DisplayMessage {
  TutorialMessage(super.parts);
}

class TagsChanged extends DisplayMessage {
  final Player player;
  final List<String> tags;

  TagsChanged(super.parts, this.player, this.tags);
}

class CommandResult extends DisplayMessage {
  CommandResult(super.parts);
}

class AdminCommandResult extends DisplayMessage {
  AdminCommandResult(super.parts);
}

class GoalReached extends DisplayMessage {
  final Player player;

  GoalReached(super.parts, this.player);
}

class ItemsReleased extends DisplayMessage {
  final Player player;

  ItemsReleased(super.parts, this.player);
}

class ItemsCollected extends DisplayMessage {
  final Player player;

  ItemsCollected(super.parts, this.player);
}

class CountdownMessage extends DisplayMessage {
  final int countdown;

  CountdownMessage(super.parts, this.countdown);
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

// Corresponds to NetworkItem in the spec
class SentItem {
  final Location location;
  final Item item;
  final Player player;

  const SentItem(this.location, this.item, this.player);
}
