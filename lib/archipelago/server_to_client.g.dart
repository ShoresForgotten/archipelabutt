// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_to_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomInfo _$RoomInfoFromJson(Map<String, dynamic> json) => RoomInfo(
  NetworkVersion.fromJson(json['version'] as Map<String, dynamic>),
  NetworkVersion.fromJson(json['generator_version'] as Map<String, dynamic>),
  (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  json['password'] as bool,
  $enumDecode(_$PermissionEnumMap, json['release']),
  $enumDecode(_$PermissionEnumMap, json['collect']),
  $enumDecode(_$PermissionEnumMap, json['remaining']),
  (json['hint_cost'] as num).toInt(),
  (json['location_check_points'] as num).toInt(),
  (json['games'] as List<dynamic>).map((e) => e as String).toList(),
  Map<String, String>.from(json['datapackage_checksums'] as Map),
  json['seed_name'] as String,
  PythonTime.fromJson((json['time'] as num).toDouble()),
);

Map<String, dynamic> _$RoomInfoToJson(RoomInfo instance) => <String, dynamic>{
  'version': instance.version.toJson(),
  'generator_version': instance.generatorVersion.toJson(),
  'tags': instance.tags,
  'password': instance.password,
  'release': _$PermissionEnumMap[instance.release]!,
  'collect': _$PermissionEnumMap[instance.collect]!,
  'remaining': _$PermissionEnumMap[instance.remaining]!,
  'hint_cost': instance.hintCost,
  'location_check_points': instance.locationCheckPoints,
  'games': instance.games,
  'datapackage_checksums': instance.datapackageChecksums,
  'seed_name': instance.seedName,
  'time': instance.time.toJson(),
};

const _$PermissionEnumMap = {
  Permission.disabled: 0,
  Permission.enabled: 1,
  Permission.goal: 2,
  Permission.auto: 6,
  Permission.autoEnabled: 7,
};

ConnectionRefused _$ConnectionRefusedFromJson(Map<String, dynamic> json) =>
    ConnectionRefused(
      (json['errors'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ConnectionRefusedReasonEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$ConnectionRefusedToJson(ConnectionRefused instance) =>
    <String, dynamic>{
      'errors':
          instance.errors
              ?.map((e) => _$ConnectionRefusedReasonEnumMap[e]!)
              .toList(),
    };

const _$ConnectionRefusedReasonEnumMap = {
  ConnectionRefusedReason.invalidSlot: 'InvalidSlot',
  ConnectionRefusedReason.invalidGame: 'InvalidGame',
  ConnectionRefusedReason.incompatibleVersion: 'IncompatibleVersion',
  ConnectionRefusedReason.invalidPassword: 'InvalidPassword',
  ConnectionRefusedReason.invalidItemsHandling: 'InvalidItemsHandling',
};

Connected _$ConnectedFromJson(Map<String, dynamic> json) => Connected(
  (json['team'] as num).toInt(),
  (json['slot'] as num).toInt(),
  (json['players'] as List<dynamic>)
      .map((e) => NetworkPlayer.fromJson(e as Map<String, dynamic>))
      .toList(),
  (json['missing_locations'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  (json['checked_locations'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  (json['slot_info'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(int.parse(k), NetworkSlot.fromJson(e as Map<String, dynamic>)),
  ),
  (json['hint_points'] as num).toInt(),
  json['slot_data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ConnectedToJson(Connected instance) => <String, dynamic>{
  'team': instance.team,
  'slot': instance.slot,
  'players': instance.players.map((e) => e.toJson()).toList(),
  'missing_locations': instance.missingLocations,
  'checked_locations': instance.checkedLocations,
  'slot_data': instance.slotData,
  'slot_info': instance.slotInfo.map(
    (k, e) => MapEntry(k.toString(), e.toJson()),
  ),
  'hint_points': instance.hintPoints,
};

ReceivedItems _$ReceivedItemsFromJson(Map<String, dynamic> json) =>
    ReceivedItems(
      (json['index'] as num).toInt(),
      (json['items'] as List<dynamic>)
          .map((e) => NetworkItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReceivedItemsToJson(ReceivedItems instance) =>
    <String, dynamic>{
      'index': instance.index,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

LocationInfo _$LocationInfoFromJson(Map<String, dynamic> json) => LocationInfo(
  (json['locations'] as List<dynamic>)
      .map((e) => NetworkItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LocationInfoToJson(LocationInfo instance) =>
    <String, dynamic>{
      'locations': instance.locations.map((e) => e.toJson()).toList(),
    };

RoomUpdate _$RoomUpdateFromJson(Map<String, dynamic> json) => RoomUpdate(
  players:
      (json['players'] as List<dynamic>?)
          ?.map((e) => NetworkPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
  checkedLocations:
      (json['checked_locations'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
);

Map<String, dynamic> _$RoomUpdateToJson(RoomUpdate instance) =>
    <String, dynamic>{
      'players': instance.players?.map((e) => e.toJson()).toList(),
      'checked_locations': instance.checkedLocations,
    };

PrintJSON _$PrintJSONFromJson(Map<String, dynamic> json) => PrintJSON(
  (json['data'] as List<dynamic>)
      .map((e) => JSONMessagePart.fromJson(e as Map<String, dynamic>))
      .toList(),
  type: $enumDecodeNullable(_$PrintJSONTypeEnumMap, json['type']),
  receiving: (json['receiving'] as num?)?.toInt(),
  item:
      json['item'] == null
          ? null
          : NetworkItem.fromJson(json['item'] as Map<String, dynamic>),
  found: json['found'] as bool?,
  team: (json['team'] as num?)?.toInt(),
  slot: (json['slot'] as num?)?.toInt(),
  message: json['message'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  countdown: (json['countdown'] as num?)?.toInt(),
);

Map<String, dynamic> _$PrintJSONToJson(PrintJSON instance) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'type': _$PrintJSONTypeEnumMap[instance.type],
  'receiving': instance.receiving,
  'item': instance.item?.toJson(),
  'found': instance.found,
  'team': instance.team,
  'slot': instance.slot,
  'message': instance.message,
  'tags': instance.tags,
  'countdown': instance.countdown,
};

const _$PrintJSONTypeEnumMap = {
  PrintJSONType.itemsend: 'ItemSend',
  PrintJSONType.itemcheat: 'ItemCheat',
  PrintJSONType.hint: 'Hint',
  PrintJSONType.join: 'Join',
  PrintJSONType.part: 'Part',
  PrintJSONType.chat: 'Chat',
  PrintJSONType.serverChat: 'ServerChat',
  PrintJSONType.tutorial: 'Tutorial',
  PrintJSONType.tagsChanged: 'TagsChanged',
  PrintJSONType.commandResult: 'CommandResult',
  PrintJSONType.adminCommandResult: 'AdminCommandResult',
  PrintJSONType.goal: 'Goal',
  PrintJSONType.release: 'Release',
  PrintJSONType.collect: 'Collect',
  PrintJSONType.countdown: 'Countdown',
};

DataPackage _$DataPackageFromJson(Map<String, dynamic> json) => DataPackage(
  DataPackageContents.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DataPackageToJson(DataPackage instance) =>
    <String, dynamic>{'data': instance.data.toJson()};

Bounced _$BouncedFromJson(Map<String, dynamic> json) => Bounced(
  json['data'] as Map<String, dynamic>,
  games: (json['games'] as List<dynamic>?)?.map((e) => e as String).toList(),
  slots:
      (json['slots'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$BouncedToJson(Bounced instance) => <String, dynamic>{
  'games': instance.games,
  'slots': instance.slots,
  'tags': instance.tags,
  'data': instance.data,
};

InvalidPacket _$InvalidPacketFromJson(Map<String, dynamic> json) =>
    InvalidPacket(
      $enumDecode(_$PacketProblemTypeEnumMap, json['type']),
      json['original_command'] as String?,
      json['text'] as String,
    );

Map<String, dynamic> _$InvalidPacketToJson(InvalidPacket instance) =>
    <String, dynamic>{
      'type': _$PacketProblemTypeEnumMap[instance.type]!,
      'original_command': instance.originalCommand,
      'text': instance.text,
    };

const _$PacketProblemTypeEnumMap = {
  PacketProblemType.cmd: 'cmd',
  PacketProblemType.arguments: 'arguments',
};

Retrieved _$RetrievedFromJson(Map<String, dynamic> json) =>
    Retrieved(json['keys'] as Map<String, dynamic>);

Map<String, dynamic> _$RetrievedToJson(Retrieved instance) => <String, dynamic>{
  'keys': instance.keys,
};

SetReply _$SetReplyFromJson(Map<String, dynamic> json) => SetReply(
  json['key'] as String,
  json['value'],
  json['original_value'],
  (json['slot'] as num).toInt(),
);

Map<String, dynamic> _$SetReplyToJson(SetReply instance) => <String, dynamic>{
  'key': instance.key,
  'value': instance.value,
  'original_value': instance.originalValue,
  'slot': instance.slot,
};
