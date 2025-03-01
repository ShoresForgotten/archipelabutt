/// Common or elaborate complex types used in the archipelago network protocol.
library;

import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'protocol_types.g.dart';

/// Information about a player in a session.
@JsonSerializable()
class NetworkPlayer {
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
class NetworkItem {
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

  @override
  int get hashCode => Object.hash(item, location, player, flags);

  @override
  bool operator ==(Object other) {
    return other is NetworkItem &&
        other.item == item &&
        other.location == location &&
        other.player == player &&
        other.flags == flags;
  }
}

/// Flags for information about an item.
class NetworkItemFlags {
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

  @override
  int get hashCode => Object.hash(logicalAdvancement, useful, trap);

  @override
  bool operator ==(Object other) {
    return other is NetworkItemFlags &&
        other.logicalAdvancement == logicalAdvancement &&
        other.useful == useful &&
        other.trap == trap;
  }
}

/// Part of a message sent with PrintJSON.
sealed class JSONMessagePart {
  final String text;

  const JSONMessagePart(this.text);

  Map<String, dynamic> toJson();

  factory JSONMessagePart.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('type')) {
      String type = json['type'];
      switch (type) {
        case 'text':
          return TextJSONMessagePart.fromJson(json);
        case 'player_id':
          return PlayerIDJSONMessagePart.fromJson(json);
        case 'player_name':
          return PlayerNameJSONMessagePart.fromJson(json);
        case 'item_id':
          return ItemIDJSONMessagePart.fromJson(json);
        case 'item_name':
          return ItemNameJSONMessagePart.fromJson(json);
        case 'location_id':
          return LocationIDJSONMessagePart.fromJson(json);
        case 'location_name':
          return LocationNameJSONMessagePart.fromJson(json);
        case 'entrance_name':
          return EntranceNameJSONMessagePart.fromJson(json);
        case 'hint_status':
          return HintStatusJSONMessagePart.fromJson(json);
        case 'color':
          return ColorJSONMessagePart.fromJson(json);
        default:
          throw "Invalid JSON message part type";
      }
    } else {
      return TextJSONMessagePart.fromJson(json);
    }
  }

  @override
  int get hashCode => text.hashCode;

  @override
  bool operator ==(Object other) {
    return other is JSONMessagePart && other.text == text;
  }
}

/// Default case. Just contains text.
@JsonSerializable()
class TextJSONMessagePart extends JSONMessagePart {
  final String type = 'text';

  const TextJSONMessagePart(super.text);

  factory TextJSONMessagePart.fromJson(Map<String, dynamic> json) =>
      _$TextJSONMessagePartFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TextJSONMessagePartToJson(this);

  @override
  bool operator ==(Object other) {
    return other is TextJSONMessagePart && other.text == text;
  }
}

/// Text is the player id of somebody on the client's team. Should be resolved to a name.
@JsonSerializable()
class PlayerIDJSONMessagePart extends JSONMessagePart {
  final String type = 'player_id';

  const PlayerIDJSONMessagePart(super.text);

  factory PlayerIDJSONMessagePart.fromJson(Map<String, dynamic> json) =>
      _$PlayerIDJSONMessagePartFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlayerIDJSONMessagePartToJson(this);

  @override
  bool operator ==(Object other) {
    return other is PlayerIDJSONMessagePart && other.text == text;
  }
}

/// Text is the name of a player in the session. Can't be resovled to an id.
@JsonSerializable()
class PlayerNameJSONMessagePart extends JSONMessagePart {
  final String type = 'player_name';

  const PlayerNameJSONMessagePart(super.text);

  factory PlayerNameJSONMessagePart.fromJson(Map<String, dynamic> json) =>
      _$PlayerNameJSONMessagePartFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlayerNameJSONMessagePartToJson(this);

  @override
  bool operator ==(Object other) {
    return other is PlayerNameJSONMessagePart && other.text == text;
  }
}

/// Text contains an item id, should be resolved to a name.
@JsonSerializable(explicitToJson: true)
class ItemIDJSONMessagePart extends JSONMessagePart {
  final String type = 'item_id';
  final NetworkItemFlags flags;
  final int player;

  const ItemIDJSONMessagePart(super.text, this.flags, this.player);

  factory ItemIDJSONMessagePart.fromJson(Map<String, dynamic> json) =>
      _$ItemIDJSONMessagePartFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ItemIDJSONMessagePartToJson(this);

  @override
  int get hashCode => Object.hash(text, flags, player);

  @override
  bool operator ==(Object other) {
    return other is ItemIDJSONMessagePart &&
        other.text == text &&
        other.flags == flags &&
        other.player == player;
  }
}

/// Text contains an item name. Not currently used.
@JsonSerializable(explicitToJson: true)
class ItemNameJSONMessagePart extends JSONMessagePart {
  final String type = 'item_name';
  final NetworkItemFlags flags;
  final int player;

  const ItemNameJSONMessagePart(super.text, this.flags, this.player);

  factory ItemNameJSONMessagePart.fromJson(Map<String, dynamic> json) =>
      _$ItemNameJSONMessagePartFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ItemNameJSONMessagePartToJson(this);

  @override
  int get hashCode => Object.hash(text, flags, player);

  @override
  bool operator ==(Object other) {
    return other is ItemNameJSONMessagePart &&
        other.text == text &&
        other.flags == flags &&
        other.player == player;
  }
}

/// Text contains a location id, should be resolved to a name.
@JsonSerializable()
class LocationIDJSONMessagePart extends JSONMessagePart {
  final String type = 'location_id';
  final int player;

  const LocationIDJSONMessagePart(super.text, this.player);

  factory LocationIDJSONMessagePart.fromJson(Map<String, dynamic> json) =>
      _$LocationIDJSONMessagePartFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LocationIDJSONMessagePartToJson(this);

  @override
  int get hashCode => Object.hash(text, player);

  @override
  bool operator ==(Object other) {
    return other is LocationIDJSONMessagePart &&
        other.text == text &&
        other.player == player;
  }
}

/// Text contains a location name. Not currently used.
@JsonSerializable()
class LocationNameJSONMessagePart extends JSONMessagePart {
  final String type = 'location_name';
  final int player;

  const LocationNameJSONMessagePart(super.text, this.player);

  factory LocationNameJSONMessagePart.fromJson(Map<String, dynamic> json) =>
      _$LocationNameJSONMessagePartFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LocationNameJSONMessagePartToJson(this);

  @override
  int get hashCode => Object.hash(text, player);

  @override
  bool operator ==(Object other) {
    return other is LocationNameJSONMessagePart &&
        other.text == text &&
        other.player == player;
  }
}

/// Text contains an entrance name. No id mapping.
@JsonSerializable()
class EntranceNameJSONMessagePart extends JSONMessagePart {
  final String type = 'entrance_name';

  const EntranceNameJSONMessagePart(super.text);

  factory EntranceNameJSONMessagePart.fromJson(Map<String, dynamic> json) =>
      _$EntranceNameJSONMessagePartFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EntranceNameJSONMessagePartToJson(this);

  @override
  bool operator ==(Object other) {
    return other is EntranceNameJSONMessagePart && other.text == text;
  }
}

/// The [HintStatus] of a hint.
@JsonSerializable()
class HintStatusJSONMessagePart extends JSONMessagePart {
  final String type = 'hint_status';
  final HintStatus status;

  const HintStatusJSONMessagePart(super.text, this.status);

  @override
  Map<String, dynamic> toJson() => _$HintStatusJSONMessagePartToJson(this);

  factory HintStatusJSONMessagePart.fromJson(Map<String, dynamic> json) =>
      _$HintStatusJSONMessagePartFromJson(json);

  @override
  int get hashCode => Object.hash(text, status);

  @override
  bool operator ==(Object other) {
    return other is HintStatusJSONMessagePart &&
        other.text == text &&
        other.status == status;
  }
}

/// Regular text that should be colored.
@JsonSerializable()
class ColorJSONMessagePart extends JSONMessagePart {
  final String type = 'color';
  final ConsoleColor color;

  const ColorJSONMessagePart(super.text, this.color);

  @override
  Map<String, dynamic> toJson() => _$ColorJSONMessagePartToJson(this);

  factory ColorJSONMessagePart.fromJson(Map<String, dynamic> json) =>
      _$ColorJSONMessagePartFromJson(json);

  @override
  int get hashCode => Object.hash(text, color);

  @override
  bool operator ==(Object other) {
    return other is ColorJSONMessagePart &&
        other.text == text &&
        other.color == color;
  }
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
class NetworkVersion {
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
class SlotType {
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

  @override
  int get hashCode => Object.hash(player, group);

  @override
  bool operator ==(Object other) {
    return other is SlotType && other.player == player && other.group == group;
  }
}

/// Static information about a slot.
@JsonSerializable(explicitToJson: true)
class NetworkSlot {
  @JsonKey(name: 'class', includeToJson: true, required: false)
  final String classKey = 'NetworkSlot';
  final String name;
  final String game;
  final SlotType type;
  final List<int>? groupMembers;

  const NetworkSlot(this.name, this.game, this.type, this.groupMembers);

  factory NetworkSlot.fromJson(Map<String, dynamic> json) =>
      _$NetworkSlotFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkSlotToJson(this);

  @override
  int get hashCode => Object.hash(name, game, type, groupMembers);

  @override
  bool operator ==(Object other) {
    return other is NetworkSlot &&
        other.name == name &&
        other.game == game &&
        other.type == type &&
        ListEquality().equals(other.groupMembers, groupMembers);
  }
}

@JsonSerializable(explicitToJson: true)
class PermissionsDict {
  final Permission release;
  final Permission collect;
  final Permission remaining;

  const PermissionsDict(this.release, this.collect, this.remaining);

  factory PermissionsDict.fromJson(Map<String, dynamic> json) =>
      _$PermissionsDictFromJson(json);

  Map<String, dynamic> toJson() => _$PermissionsDictToJson(this);

  @override
  int get hashCode => Object.hash(release, collect, remaining);

  @override
  bool operator ==(Object other) {
    return other is PermissionsDict &&
        other.release == release &&
        other.collect == collect &&
        other.remaining == remaining;
  }
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
class Hint {
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

  @override
  int get hashCode => Object.hash(
    receivingPlayer,
    findingPlayer,
    location,
    item,
    found,
    entrance,
    flags,
    status,
  );

  @override
  bool operator ==(Object other) {
    return other is Hint &&
        other.receivingPlayer == receivingPlayer &&
        other.findingPlayer == findingPlayer &&
        other.location == location &&
        other.item == item &&
        other.found == found &&
        other.entrance == entrance &&
        other.flags == flags &&
        other.status == status;
  }
}

@JsonSerializable(explicitToJson: true)
class DataPackageContents {
  final Map<String, GameData> games;

  DataPackageContents(this.games);

  factory DataPackageContents.fromJson(Map<String, dynamic> json) =>
      _$DataPackageContentsFromJson(json);

  Map<String, dynamic> toJson() => _$DataPackageContentsToJson(this);

  @override
  int get hashCode => games.hashCode;

  @override
  bool operator ==(Object other) {
    return other is DataPackageContents &&
        MapEquality().equals(other.games, games);
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GameData {
  final Map<String, int> itemNameToId;
  final Map<String, int> locationNameToId;
  final String checksum;

  GameData(this.itemNameToId, this.locationNameToId, this.checksum);

  factory GameData.fromJson(Map<String, dynamic> json) =>
      _$GameDataFromJson(json);

  Map<String, dynamic> toJson() => _$GameDataToJson(this);

  @override
  int get hashCode => Object.hash(itemNameToId, locationNameToId, checksum);

  @override
  bool operator ==(Object other) {
    final MapEquality me = MapEquality();
    return other is GameData &&
        me.equals(other.itemNameToId, itemNameToId) &&
        me.equals(locationNameToId, locationNameToId) &&
        other.checksum == checksum;
  }
}

/// Deathlink information.
@JsonSerializable(explicitToJson: true)
class DeathLink {
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

  @override
  int get hashCode => Object.hash(time, cause, source);

  @override
  bool operator ==(Object other) {
    return other is DeathLink &&
        other.time == time &&
        other.cause == cause &&
        other.source == source;
  }
}

double toPythonTimeJson(DateTime time) =>
    (time.millisecondsSinceEpoch / 1000).toDouble();

DateTime fromPythonTimeJson(double time) =>
    DateTime.fromMillisecondsSinceEpoch((time * 1000).floor());

double? nullableToPythonTimeJson(DateTime? time) =>
    (time == null) ? null : toPythonTimeJson(time);

DateTime? nullableFromPythonTimeJson(double? time) =>
    (time == null) ? null : fromPythonTimeJson(time);
