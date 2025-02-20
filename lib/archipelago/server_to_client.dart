library;

import 'package:json_annotation/json_annotation.dart';

import 'protocol_types.dart';

part 'server_to_client.g.dart';

sealed class ServerMessage {
  abstract final String cmd;
  static ServerMessage fromJson(Map<String, dynamic> json) {
    final String cmd = json['cmd'];
    switch (cmd) {
      case 'RoomInfo':
        return RoomInfo.fromJson(json);
      case 'ConnectionRefused':
        return ConnectionRefused.fromJson(json);
      case 'Connected':
        return Connected.fromJson(json);
      case 'ReceivedItems':
        return ReceivedItems.fromJson(json);
      case 'LocationInfo':
        return LocationInfo.fromJson(json);
      case 'RoomUpdate':
        return RoomUpdate.fromJson(json);
      case 'PrintJSON':
        return PrintJSON.fromJson(json);
      case 'DataPackage':
        return DataPackage.fromJson(json);
      case 'Bounced':
        return Bounced.fromJson(json);
      case 'InvalidPacket':
        return InvalidPacket.fromJson(json);
      case 'Retrieved':
        return Retrieved.fromJson(json);
      case 'SetReply':
        return SetReply.fromJson(json);
      default:
        throw 'Invalid message command';
    }
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
final class RoomInfo extends ServerMessage {
  @override
  final String cmd = 'RoomInfo';
  final NetworkVersion version;
  final NetworkVersion generatorVersion;
  final List<String> tags;
  final bool password;
  final Permission release;
  final Permission collect;
  final Permission remaining;
  final int hintCost;
  final int locationCheckPoints;
  final List<String> games;
  final Map<String, String> datapackageChecksums;
  final String seedName;
  @JsonKey(fromJson: fromPythonTimeJson, toJson: toPythonTimeJson)
  final DateTime time;
  RoomInfo(
    this.version,
    this.generatorVersion,
    this.tags,
    this.password,
    this.release,
    this.collect,
    this.remaining,
    this.hintCost,
    this.locationCheckPoints,
    this.games,
    this.datapackageChecksums,
    this.seedName,
    this.time,
  );

  factory RoomInfo.fromJson(Map<String, dynamic> json) =>
      _$RoomInfoFromJson(json);

  Map<String, dynamic> toJson() => _$RoomInfoToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class ConnectionRefused extends ServerMessage {
  @override
  final String cmd = "ConnectionRefused";
  final List<ConnectionRefusedReason>? errors;

  ConnectionRefused([this.errors]);

  factory ConnectionRefused.fromJson(Map<String, dynamic> json) =>
      _$ConnectionRefusedFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionRefusedToJson(this);
}

@JsonEnum(fieldRename: FieldRename.pascal)
enum ConnectionRefusedReason {
  invalidSlot,
  invalidGame,
  incompatibleVersion,
  invalidPassword,
  invalidItemsHandling,
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
final class Connected extends ServerMessage {
  @override
  final String cmd = "Connected";
  final int team;
  final int slot;
  final List<NetworkPlayer> players;
  final List<int> missingLocations;
  final List<int> checkedLocations;

  /// Slot related data, differs per game.
  /// Empty if not required, not present if slot_data in Connect is false.
  final Map<String, dynamic>? slotData;
  final Map<int, NetworkSlot> slotInfo;
  final int hintPoints;

  Connected(
    this.team,
    this.slot,
    this.players,
    this.missingLocations,
    this.checkedLocations,
    this.slotInfo,
    this.hintPoints, [
    this.slotData,
  ]);

  factory Connected.fromJson(Map<String, dynamic> json) =>
      _$ConnectedFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectedToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class ReceivedItems extends ServerMessage {
  @override
  final String cmd = "ReceivedItems";
  final int index;
  final List<NetworkItem> items;

  ReceivedItems(this.index, this.items);

  factory ReceivedItems.fromJson(Map<String, dynamic> json) =>
      _$ReceivedItemsFromJson(json);

  Map<String, dynamic> toJson() => _$ReceivedItemsToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class LocationInfo extends ServerMessage {
  @override
  final String cmd = "LocationInfo";
  final List<NetworkItem> locations;

  LocationInfo(this.locations);

  factory LocationInfo.fromJson(Map<String, dynamic> json) =>
      _$LocationInfoFromJson(json);

  Map<String, dynamic> toJson() => _$LocationInfoToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
final class RoomUpdate extends ServerMessage {
  @override
  final String cmd = "RoomUpdate";
  final List<NetworkPlayer>? players;
  final List<int>? checkedLocations;

  RoomUpdate({this.players, this.checkedLocations});

  factory RoomUpdate.fromJson(Map<String, dynamic> json) =>
      _$RoomUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$RoomUpdateToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class PrintJSON extends ServerMessage {
  @override
  final String cmd = "PrintJSON";
  final List<JSONMessagePart> data;
  final PrintJSONType? type;
  final int? receiving;
  final NetworkItem? item;
  final bool? found;
  final int? team;
  final int? slot;
  final String? message;
  final List<String>? tags;
  final int? countdown;

  PrintJSON(
    this.data, {
    this.type,
    this.receiving,
    this.item,
    this.found,
    this.team,
    this.slot,
    this.message,
    this.tags,
    this.countdown,
  });

  factory PrintJSON.fromJson(Map<String, dynamic> json) =>
      _$PrintJSONFromJson(json);

  Map<String, dynamic> toJson() => _$PrintJSONToJson(this);
}

@JsonEnum(valueField: 'text')
enum PrintJSONType {
  itemsend("ItemSend"),
  itemcheat("ItemCheat"),
  hint("Hint"),
  join("Join"),
  part("Part"),
  chat("Chat"),
  serverChat("ServerChat"),
  tutorial("Tutorial"),
  tagsChanged("TagsChanged"),
  commandResult("CommandResult"),
  adminCommandResult("AdminCommandResult"),
  goal("Goal"),
  release("Release"),
  collect("Collect"),
  countdown("Countdown");

  final String text;
  const PrintJSONType(this.text);
}

@JsonSerializable(explicitToJson: true)
final class DataPackage extends ServerMessage {
  @override
  final String cmd = "DataPackage";
  final DataPackageContents data;

  DataPackage(this.data);

  factory DataPackage.fromJson(Map<String, dynamic> json) =>
      _$DataPackageFromJson(json);

  Map<String, dynamic> toJson() => _$DataPackageToJson(this);
}

@JsonSerializable()
final class Bounced extends ServerMessage {
  @override
  final String cmd = "Bounced";
  final List<String>? games;
  final List<int>? slots;
  final List<String>? tags;
  final Map<dynamic, dynamic> data;

  Bounced(this.data, {this.games, this.slots, this.tags});

  factory Bounced.fromJson(Map<String, dynamic> json) =>
      _$BouncedFromJson(json);

  Map<String, dynamic> toJson() => _$BouncedToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
final class InvalidPacket extends ServerMessage {
  @override
  final String cmd = "InvalidPacket";
  final PacketProblemType type;
  final String? originalCommand;
  final String text;

  InvalidPacket(this.type, this.originalCommand, this.text);

  factory InvalidPacket.fromJson(Map<String, dynamic> json) =>
      _$InvalidPacketFromJson(json);

  Map<String, dynamic> toJson() => _$InvalidPacketToJson(this);
}

@JsonEnum()
enum PacketProblemType { cmd, arguments }

@JsonSerializable()
final class Retrieved extends ServerMessage {
  @override
  final String cmd = "Retrieved";
  final Map<String, dynamic> keys;

  Retrieved(this.keys);

  factory Retrieved.fromJson(Map<String, dynamic> json) =>
      _$RetrievedFromJson(json);

  Map<String, dynamic> toJson() => _$RetrievedToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
final class SetReply extends ServerMessage {
  @override
  final String cmd = "SetReply";
  final String key;
  final dynamic value;
  final dynamic originalValue;
  final int slot;

  SetReply(this.key, this.value, this.originalValue, this.slot);

  factory SetReply.fromJson(Map<String, dynamic> json) =>
      _$SetReplyFromJson(json);

  Map<String, dynamic> toJson() => _$SetReplyToJson(this);
}
