/// Common or elaborate data types used in the archipelago network protocol.
library;

import 'dart:js_interop';

import 'package:json_annotation/json_annotation.dart';

part 'protocol_types.g.dart';

/// Information about a player in a session.
@JsonSerializable()
final class NetworkPlayer {
  /// Team to which the player belongs. Starts at 0.
  final int team;

  /// Player slot. Numbers are unique per team. Starts at 1.
  final int slot;

  /// Player's current in-game name.
  final String alias;

  /// Original name used when the session was generated.
  final String name;
  const NetworkPlayer(this.team, this.slot, this.alias, this.name);

  factory NetworkPlayer.fromJSON(Map<String, dynamic> json) =>
      _$NetworkPlayerFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkPlayerToJson(this);
}

/// Information about an item.
@JsonSerializable(explicitToJson: true)
final class NetworkItem {
  /// Item ID of the item. Within the of -2^53 + 1 to 2^53 -1, inclusive.
  /// Values below 0 are reserved for Archipelago use.
  final int item;

  /// Location id of the item. Same range as item id.
  final int location;

  /// Player slot of the player whose world contains the item.
  /// When inside a LocationInfo instead has the player who receives the item.
  final int player;

  /// Flags indicating notable things about the item.
  final NetworkItemFlags flags;
  const NetworkItem(this.item, this.location, this.player, this.flags);

  factory NetworkItem.fromJson(Map<String, dynamic> json) =>
      _$NetworkItemFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkItemToJson(this);
}

/// Flags for information about an item.
final class NetworkItemFlags {
  /// Does this item unlock a logical advancement?
  final bool logicalAdvancement;

  /// Is this item especially useful?
  final bool useful;

  /// Is this item a trap?
  final bool trap;
  const NetworkItemFlags({
    this.logicalAdvancement = false,
    this.useful = false,
    this.trap = false,
  });

  /// Static const object for const constructors.
  static const emptyFlags = NetworkItemFlags();

  factory NetworkItemFlags.fromJson(int flags) {
    bool advancement = false;
    bool useful = false;
    bool trap = false;
    if ((flags & 1) == 1) {
      advancement = true;
    }
    if ((flags & 2) == 2) {
      useful = true;
    }
    if ((flags & 4) == 4) {
      trap = true;
    }
    return NetworkItemFlags(
      logicalAdvancement: advancement,
      useful: useful,
      trap: trap,
    );
  }

  int toJson() {
    int flags = 0;
    if (logicalAdvancement) {
      flags += 1;
    }
    if (useful) {
      flags += 2;
    }
    if (trap) {
      flags += 4;
    }
    return flags;
  }
}

/// Part of a message sent with PrintJSON.
sealed class JSONMessagePart {
  final String text;
  const JSONMessagePart(this.text);

  factory JSONMessagePart.fromJson(Map<String, dynamic> json) {
    String type = json['type'];
    String text = json['text'];
    switch (type) {
      case 'text':
        return TextMessagePart(text);
      case 'player_id':
        return PlayerIDMessagePart(text);
      case 'player_name':
        return PlayerNameMessagePart(text);
      case 'item_id':
        return ItemIDMessagePart.fromJson(json);
      case 'item_name':
        return ItemNameMessagePart.fromJson(json);
      case 'location_id':
        return LocationIDMessagePart.fromJson(json);
      case 'location_name':
        return LocationNameMessagePart.fromJson(json);
      case 'entrance_name':
        return EntranceNameMessagePart(text);
      case 'hint_status':
        return HintStatusMessagePart.fromJson(json);
      case 'color':
        return ColorMessagePart.fromJson(json);
      default:
        throw "Invalid JSON message part type";
    }
  }
}

/// Default case. Just contains text.
@JsonSerializable()
final class TextMessagePart extends JSONMessagePart {
  final String type = 'text';
  const TextMessagePart(super.text);
  Map<String, dynamic> toJson() => _$TextMessagePartToJson(this);
}

/// Text is the player id of somebody on the client's team. Should be resolved to a name.
@JsonSerializable()
final class PlayerIDMessagePart extends JSONMessagePart {
  final String type = 'player_id';
  const PlayerIDMessagePart(super.text);
  Map<String, dynamic> toJson() => _$PlayerIDMessagePartToJson(this);
}

/// Text is the name of a player in the session. Can't be resovled to an id.
@JsonSerializable()
final class PlayerNameMessagePart extends JSONMessagePart {
  final String type = 'player_name';
  const PlayerNameMessagePart(super.text);
  Map<String, dynamic> toJson() => _$PlayerNameMessagePartToJson(this);
}

/// Text contains an item id, should be resolved to a name.
@JsonSerializable(explicitToJson: true)
final class ItemIDMessagePart extends JSONMessagePart {
  final String type = 'item_id';
  final NetworkItemFlags flags;
  final int player;

  const ItemIDMessagePart(super.text, this.flags, this.player);

  Map<String, dynamic> toJson() => _$ItemIDMessagePartToJson(this);

  factory ItemIDMessagePart.fromJson(Map<String, dynamic> json) =>
      _$ItemIDMessagePartFromJson(json);
}

/// Text contains an item name. Not currently used.
@JsonSerializable(explicitToJson: true)
final class ItemNameMessagePart extends JSONMessagePart {
  final String type = 'item_name';
  final NetworkItemFlags flags;
  final int player;

  const ItemNameMessagePart(super.text, this.flags, this.player);

  Map<String, dynamic> toJson() => _$ItemNameMessagePartToJson(this);

  factory ItemNameMessagePart.fromJson(Map<String, dynamic> json) =>
      _$ItemNameMessagePartFromJson(json);
}

/// Text contains a location id, should be resolved to a name.
@JsonSerializable()
final class LocationIDMessagePart extends JSONMessagePart {
  final String type = 'location_id';
  final int player;

  const LocationIDMessagePart(super.text, this.player);

  Map<String, dynamic> toJson() => _$LocationIDMessagePartToJson(this);

  factory LocationIDMessagePart.fromJson(Map<String, dynamic> json) =>
      _$LocationIDMessagePartFromJson(json);
}

/// Text contains a location name. Not currently used.
@JsonSerializable()
final class LocationNameMessagePart extends JSONMessagePart {
  final String type = 'location_name';
  final int player;

  const LocationNameMessagePart(super.text, this.player);

  Map<String, dynamic> toJson() => _$LocationNameMessagePartToJson(this);

  factory LocationNameMessagePart.fromJson(Map<String, dynamic> json) =>
      _$LocationNameMessagePartFromJson(json);
}

/// Text contains an entrance name. No id mapping.
@JsonSerializable()
final class EntranceNameMessagePart extends JSONMessagePart {
  final String type = 'entrance_name';

  const EntranceNameMessagePart(super.text);

  Map<String, dynamic> toJson() => _$EntranceNameMessagePartToJson(this);
}

/// The [HintStatus] of a hint.
@JsonSerializable()
final class HintStatusMessagePart extends JSONMessagePart {
  final String type = 'hint_status';
  final HintStatus status;

  const HintStatusMessagePart(super.text, this.status);

  Map<String, dynamic> toJson() => _$HintStatusMessagePartToJson(this);

  factory HintStatusMessagePart.fromJson(Map<String, dynamic> json) =>
      _$HintStatusMessagePartFromJson(json);
}

/// Regular text that should be colored.
@JsonSerializable()
final class ColorMessagePart extends JSONMessagePart {
  final String type = 'color';
  final ConsoleColor color;

  const ColorMessagePart(super.text, this.color);

  Map<String, dynamic> toJson() => _$ColorMessagePartToJson(this);

  factory ColorMessagePart.fromJson(Map<String, dynamic> json) =>
      _$ColorMessagePartFromJson(json);
}

/// The variations of hint statuses.
@JsonEnum(valueField: 'value')
enum HintStatus {
  unspecified(0),
  noPriority(10),
  avoid(20),
  priority(30),
  found(40);

  final int value;
  const HintStatus(this.value);
}

/// The possible colors of a color message.
@JsonEnum(valueField: 'representation')
enum ConsoleColor {
  bold("bold"),
  underline("underline"),
  black("black"),
  red("red"),
  green("green"),
  yellow("yellow"),
  blue("blue"),
  magenta("magenta"),
  cyan("cyan"),
  white("white"),
  blackBackground("black_bg"),
  redBackground("red_bg"),
  greenBackground("green_bg"),
  yellowBackground("yellow_bg"),
  blueBackground("blue_bg"),
  magentaBackground("magenta_bg"),
  cyanBackground("cyan_bg"),
  whiteBackground("white_bg");

  final String representation;
  const ConsoleColor(this.representation);
}

/// The current status of a client.
@JsonEnum(valueField: 'value')
enum ClientStatus {
  unknown(0),
  connected(5),
  ready(10),
  playing(20),
  goal(30);

  /// Integer value of the enum
  final int value;
  const ClientStatus(this.value);
}

/// A version of software. Used to communicate Archipelago versions.
@JsonSerializable()
final class NetworkVersion {
  final int major;
  final int minor;
  final int build;

  const NetworkVersion(this.major, this.minor, this.build);

  factory NetworkVersion.fromJson(Map<String, dynamic> json) =>
      _$NetworkVersionFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkVersionToJson(this);
}

/// Flags representing the nature of a slot
final class SlotType {
  /// True if slot is a player, false if it's a spectator
  final bool player;
  final bool group;
  const SlotType(this.player, this.group);
  factory SlotType.fromJson(int flags) {
    bool player = false;
    bool group = false;
    if (flags & 1 == 1) {
      player = true;
    }
    if (flags & 2 == 2) {
      group = true;
    }
    return SlotType(player, group);
  }
  int toJson() {
    int flags = 0;
    if (player) {
      flags += 1;
    }
    if (group) {
      flags += 2;
    }
    return flags;
  }
}

/// Static information about a slot.
@JsonSerializable(explicitToJson: true)
final class NetworkSlot {
  final String name;
  final String game;
  final SlotType type;
  final List<int> groupMembers;

  const NetworkSlot(this.name, this.game, this.type, this.groupMembers);

  factory NetworkSlot.fromJson(Map<String, dynamic> json) =>
      _$NetworkSlotFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkSlotToJson(this);
}

/// Permissions for commands.
@JsonEnum(valueField: 'value')
enum Permission {
  disabled(0),
  enabled(1),
  goal(2),
  auto(6),
  autoEnabled(7);

  final int value;

  const Permission(this.value);
}

/// Hint information.
@JsonSerializable(explicitToJson: true)
final class Hint {
  final int receivingPlayer;
  final int findingPlayer;
  final int location;
  final int item;
  final bool found;
  final String entrance;
  final NetworkItemFlags flags;
  final HintStatus status;

  const Hint(
    this.receivingPlayer,
    this.findingPlayer,
    this.location,
    this.item,
    this.found, {
    this.entrance = "",
    this.flags = NetworkItemFlags.emptyFlags,
    this.status = HintStatus.unspecified,
  });

  factory Hint.fromJson(Map<String, dynamic> json) => _$HintFromJson(json);

  Map<String, dynamic> toJson() => _$HintToJson(this);
}

final class DataPackageContents {
  // TODO: Data Package Contents
  // https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#data-package-contents
}

@JsonEnum(valueField: 'name')
enum Tag {
  ap("AP", true),
  deathlink("DeathLink", true),
  hintgame("HintGame", false),
  tracker("Tracker", false),
  textonly("TextOnly", false),
  notext("NoText", true);

  final String name;
  final bool needsGame;

  const Tag(this.name, this.needsGame);
}

/// Deathlink information.
final class DeathLink {
  /// Time of death.
  final DateTime time;

  /// Optional cause of death.
  final String? cause;

  /// Name of the player who caused the deathlink.
  final String source;
  const DeathLink(this.time, this.source, [this.cause]);

  factory DeathLink.fromJson(Map<String, dynamic> json) {
    double timeFloat = json['time'];
    DateTime time = DateTime.fromMillisecondsSinceEpoch(
      timeFloat.floor() * 1000,
    );
    String source = json['source'];
    String? cause = json['cause'];
    if (cause == null || cause == "") {
      return DeathLink(time, source);
    } else {
      return DeathLink(time, source, cause);
    }
  }
}
