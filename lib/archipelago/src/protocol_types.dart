/// Common or elaborate complex types used in the archipelago network protocol.
library;

import 'package:json_annotation/json_annotation.dart';

part 'protocol_types.g.dart';

/// Information about a player in a session.
@JsonSerializable()
final class NetworkPlayer {
  @JsonKey(name: 'class', includeToJson: true, required: false)
  final String classKey = 'NetworkPlayer';

  /// Team to which the player belongs. Starts at 0.
  final int team;

  /// Player slot. Numbers are unique per team. Starts at 1.
  final int slot;

  /// Player's current in-game name.
  final String alias;

  /// Original name used when the session was generated.
  final String name;
  const NetworkPlayer(this.team, this.slot, this.alias, this.name);

  factory NetworkPlayer.fromJson(Map<String, dynamic> json) =>
      _$NetworkPlayerFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkPlayerToJson(this);

  @override
  int get hashCode => Object.hash(team, slot, alias, name);

  @override
  bool operator ==(Object other) {
    return other is NetworkPlayer &&
        other.team == team &&
        other.slot == slot &&
        other.alias == alias &&
        other.name == name;
  }
}

/// Information about an item.
@JsonSerializable(explicitToJson: true)
final class NetworkItem {
  @JsonKey(name: 'class', includeToJson: true, required: false)
  final String classKey = 'NetworkItem';

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

  Map<String, dynamic> toJson();

  factory JSONMessagePart.fromJson(Map<String, dynamic> json) {
    String type = json['type'];
    switch (type) {
      case 'text':
        return TextMessagePart.fromJson(json);
      case 'player_id':
        return PlayerIDMessagePart.fromJson(json);
      case 'player_name':
        return PlayerNameMessagePart.fromJson(json);
      case 'item_id':
        return ItemIDMessagePart.fromJson(json);
      case 'item_name':
        return ItemNameMessagePart.fromJson(json);
      case 'location_id':
        return LocationIDMessagePart.fromJson(json);
      case 'location_name':
        return LocationNameMessagePart.fromJson(json);
      case 'entrance_name':
        return EntranceNameMessagePart.fromJson(json);
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

  factory TextMessagePart.fromJson(Map<String, dynamic> json) =>
      _$TextMessagePartFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TextMessagePartToJson(this);
}

/// Text is the player id of somebody on the client's team. Should be resolved to a name.
@JsonSerializable()
final class PlayerIDMessagePart extends JSONMessagePart {
  final String type = 'player_id';

  const PlayerIDMessagePart(super.text);

  factory PlayerIDMessagePart.fromJson(Map<String, dynamic> json) =>
      _$PlayerIDMessagePartFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlayerIDMessagePartToJson(this);
}

/// Text is the name of a player in the session. Can't be resovled to an id.
@JsonSerializable()
final class PlayerNameMessagePart extends JSONMessagePart {
  final String type = 'player_name';

  const PlayerNameMessagePart(super.text);

  factory PlayerNameMessagePart.fromJson(Map<String, dynamic> json) =>
      _$PlayerNameMessagePartFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlayerNameMessagePartToJson(this);
}

/// Text contains an item id, should be resolved to a name.
@JsonSerializable(explicitToJson: true)
final class ItemIDMessagePart extends JSONMessagePart {
  final String type = 'item_id';
  final NetworkItemFlags flags;
  final int player;

  const ItemIDMessagePart(super.text, this.flags, this.player);

  factory ItemIDMessagePart.fromJson(Map<String, dynamic> json) =>
      _$ItemIDMessagePartFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ItemIDMessagePartToJson(this);
}

/// Text contains an item name. Not currently used.
@JsonSerializable(explicitToJson: true)
final class ItemNameMessagePart extends JSONMessagePart {
  final String type = 'item_name';
  final NetworkItemFlags flags;
  final int player;

  const ItemNameMessagePart(super.text, this.flags, this.player);

  factory ItemNameMessagePart.fromJson(Map<String, dynamic> json) =>
      _$ItemNameMessagePartFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ItemNameMessagePartToJson(this);
}

/// Text contains a location id, should be resolved to a name.
@JsonSerializable()
final class LocationIDMessagePart extends JSONMessagePart {
  final String type = 'location_id';
  final int player;

  const LocationIDMessagePart(super.text, this.player);

  factory LocationIDMessagePart.fromJson(Map<String, dynamic> json) =>
      _$LocationIDMessagePartFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LocationIDMessagePartToJson(this);
}

/// Text contains a location name. Not currently used.
@JsonSerializable()
final class LocationNameMessagePart extends JSONMessagePart {
  final String type = 'location_name';
  final int player;

  const LocationNameMessagePart(super.text, this.player);

  factory LocationNameMessagePart.fromJson(Map<String, dynamic> json) =>
      _$LocationNameMessagePartFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LocationNameMessagePartToJson(this);
}

/// Text contains an entrance name. No id mapping.
@JsonSerializable()
final class EntranceNameMessagePart extends JSONMessagePart {
  final String type = 'entrance_name';

  const EntranceNameMessagePart(super.text);

  factory EntranceNameMessagePart.fromJson(Map<String, dynamic> json) =>
      _$EntranceNameMessagePartFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EntranceNameMessagePartToJson(this);
}

/// The [HintStatus] of a hint.
@JsonSerializable()
final class HintStatusMessagePart extends JSONMessagePart {
  final String type = 'hint_status';
  final HintStatus status;

  const HintStatusMessagePart(super.text, this.status);

  @override
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

  @override
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
  @JsonKey(name: 'class', includeToJson: true, required: false)
  final String classKey = 'Version';
  final int major;
  final int minor;
  final int build;

  const NetworkVersion(this.major, this.minor, this.build);

  factory NetworkVersion.fromJson(Map<String, dynamic> json) =>
      _$NetworkVersionFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkVersionToJson(this);

  @override
  int get hashCode => Object.hash(major, minor, build);

  @override
  bool operator ==(Object other) {
    return other is NetworkVersion &&
        other.major == major &&
        other.minor == minor &&
        other.build == build;
  }
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
  @JsonKey(name: 'class', includeToJson: true, required: false)
  final String classKey = 'NetworkSlot';
  final String name;
  final String game;
  final SlotType type;
  final List<int> groupMembers;

  const NetworkSlot(this.name, this.game, this.type, this.groupMembers);

  factory NetworkSlot.fromJson(Map<String, dynamic> json) =>
      _$NetworkSlotFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkSlotToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class PermissionsDict {
  final Permission release;
  final Permission collect;
  final Permission remaining;

  const PermissionsDict(this.release, this.collect, this.remaining);

  factory PermissionsDict.fromJson(Map<String, dynamic> json) =>
      _$PermissionsDictFromJson(json);

  Map<String, dynamic> toJson() => _$PermissionsDictToJson(this);
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
  @JsonKey(name: 'class', includeToJson: true, required: false)
  final String classKey = 'Hint';
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

@JsonSerializable(explicitToJson: true)
final class DataPackageContents {
  final Map<String, GameData> games;

  DataPackageContents(this.games);

  factory DataPackageContents.fromJson(Map<String, dynamic> json) =>
      _$DataPackageContentsFromJson(json);

  Map<String, dynamic> toJson() => _$DataPackageContentsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
final class GameData {
  final Map<String, int> itemNameToId;
  final Map<String, int> locationNameToId;
  final String checksum;

  GameData(this.itemNameToId, this.locationNameToId, this.checksum);

  factory GameData.fromJson(Map<String, dynamic> json) =>
      _$GameDataFromJson(json);

  Map<String, dynamic> toJson() => _$GameDataToJson(this);
}

/// Deathlink information.
@JsonSerializable(explicitToJson: true)
final class DeathLink {
  /// Time of death.
  @JsonKey(toJson: toPythonTimeJson, fromJson: fromPythonTimeJson)
  final DateTime time;

  /// Optional cause of death.
  final String? cause;

  /// Name of the player who caused the deathlink.
  final String source;
  const DeathLink(this.time, this.source, [this.cause]);

  Map<String, dynamic> toJson() => _$DeathLinkToJson(this);

  factory DeathLink.fromJson(Map<String, dynamic> json) =>
      _$DeathLinkFromJson(json);
}

double toPythonTimeJson(DateTime time) =>
    (time.millisecondsSinceEpoch / 1000).toDouble();

DateTime fromPythonTimeJson(double time) =>
    DateTime.fromMillisecondsSinceEpoch((time * 1000).floor());

double? nullableToPythonTimeJson(DateTime? time) =>
    (time == null) ? null : toPythonTimeJson(time);

DateTime? nullableFromPythonTimeJson(double? time) =>
    (time == null) ? null : fromPythonTimeJson(time);
