import 'protocol_types.dart';

sealed class ServerMessage {}

final class RoomInfo extends ServerMessage {
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
}

final class ConnectionRefused extends ServerMessage {
  final List<String> errors;
  ConnectionRefused(this.errors);
}

final class Connected extends ServerMessage {
  final int team;
  final int slot;
  final List<NetworkPlayer> players;
  final List<int> missingLocations;
  final List<int> checkedLocations;
  final Map<String, dynamic> slotData;
  final Map<int, NetworkSlot> slotInfo;
  final int hintPoints;
  Connected(
    this.team,
    this.slot,
    this.players,
    this.missingLocations,
    this.checkedLocations,
    this.slotData,
    this.slotInfo,
    this.hintPoints,
  );
}

final class ReceivedItems extends ServerMessage {
  final int index;
  final List<NetworkItem> items;
  ReceivedItems(this.index, this.items);
}

final class LocationInfo extends ServerMessage {
  final List<NetworkItem> locations;
  LocationInfo(this.locations);
}

final class RoomUpdate extends ServerMessage {
  final List<NetworkPlayer> players;
  final List<int> checkedLocations;
  RoomUpdate(this.players, this.checkedLocations);
}

final class PrintJSON extends ServerMessage {
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
}

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

final class DataPackage extends ServerMessage {
  final DataPackageContents data;
  DataPackage(this.data);
}

final class Bounced extends ServerMessage {
  final List<String>? games;
  final List<int>? slots;
  final List<String>? tags;
  final Map<dynamic, dynamic> data;
  Bounced(this.data, {this.games, this.slots, this.tags});
}

final class InvalidPacket extends ServerMessage {
  final PacketProblemType type;
  final String? originalCommand;
  final String text;
  InvalidPacket(this.type, this.originalCommand, this.text);
}

enum PacketProblemType { cmd, arguments }

final class Retrieved extends ServerMessage {
  final Map<String, dynamic> keys;
  Retrieved(this.keys);
}

final class SetReply extends ServerMessage {
  final String key;
  final dynamic value;
  final dynamic originalValue;
  final int slot;
  SetReply(this.key, this.value, this.originalValue, this.slot);
}
