// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_to_server.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Connect _$ConnectFromJson(Map<String, dynamic> json) => Connect(
  json['password'] as String,
  json['game'] as String,
  json['name'] as String,
  json['uuid'] as String,
  NetworkVersion.fromJson(json['version'] as Map<String, dynamic>),
  json['items_handling'] == null
      ? null
      : ItemsHandlingFlags.fromJson((json['items_handling'] as num).toInt()),
  (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  json['slot_data'] as bool,
);

Map<String, dynamic> _$ConnectToJson(Connect instance) => <String, dynamic>{
  'password': instance.password,
  'game': instance.game,
  'name': instance.name,
  'uuid': instance.uuid,
  'version': instance.version.toJson(),
  'items_handling': instance.itemsHandling?.toJson(),
  'tags': instance.tags,
  'slot_data': instance.slotData,
};

ConnectUpdate _$ConnectUpdateFromJson(Map<String, dynamic> json) =>
    ConnectUpdate(
      ItemsHandlingFlags.fromJson((json['items_handling'] as num).toInt()),
      (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ConnectUpdateToJson(ConnectUpdate instance) =>
    <String, dynamic>{
      'items_handling': instance.itemsHandling.toJson(),
      'tags': instance.tags,
    };

Sync _$SyncFromJson(Map<String, dynamic> json) => Sync();

Map<String, dynamic> _$SyncToJson(Sync instance) => <String, dynamic>{};

LocationChecks _$LocationChecksFromJson(Map<String, dynamic> json) =>
    LocationChecks(
      (json['locations'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$LocationChecksToJson(LocationChecks instance) =>
    <String, dynamic>{'locations': instance.locations};

LocationScouts _$LocationScoutsFromJson(Map<String, dynamic> json) =>
    LocationScouts(
      (json['locations'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      (json['create_as_hint'] as num).toInt(),
    );

Map<String, dynamic> _$LocationScoutsToJson(LocationScouts instance) =>
    <String, dynamic>{
      'locations': instance.locations,
      'create_as_hint': instance.createAsHint,
    };

UpdateHint _$UpdateHintFromJson(Map<String, dynamic> json) => UpdateHint(
  (json['player'] as num).toInt(),
  (json['location'] as num).toInt(),
  $enumDecodeNullable(_$HintStatusEnumMap, json['status']),
);

Map<String, dynamic> _$UpdateHintToJson(UpdateHint instance) =>
    <String, dynamic>{
      'player': instance.player,
      'location': instance.location,
      'status': _$HintStatusEnumMap[instance.status],
    };

const _$HintStatusEnumMap = {
  HintStatus.unspecified: 0,
  HintStatus.noPriority: 10,
  HintStatus.avoid: 20,
  HintStatus.priority: 30,
  HintStatus.found: 40,
};

StatusUpdate _$StatusUpdateFromJson(Map<String, dynamic> json) =>
    StatusUpdate($enumDecode(_$ClientStatusEnumMap, json['status']));

Map<String, dynamic> _$StatusUpdateToJson(StatusUpdate instance) =>
    <String, dynamic>{'status': _$ClientStatusEnumMap[instance.status]!};

const _$ClientStatusEnumMap = {
  ClientStatus.unknown: 0,
  ClientStatus.connected: 5,
  ClientStatus.ready: 10,
  ClientStatus.playing: 20,
  ClientStatus.goal: 30,
};

Say _$SayFromJson(Map<String, dynamic> json) => Say(json['text'] as String);

Map<String, dynamic> _$SayToJson(Say instance) => <String, dynamic>{
  'text': instance.text,
};

GetDataPackage _$GetDataPackageFromJson(Map<String, dynamic> json) =>
    GetDataPackage(
      (json['games'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$GetDataPackageToJson(GetDataPackage instance) =>
    <String, dynamic>{'games': instance.games};

Bounce _$BounceFromJson(Map<String, dynamic> json) => Bounce(
  games: (json['games'] as List<dynamic>?)?.map((e) => e as String).toList(),
  slots: (json['slots'] as List<dynamic>?)?.map((e) => e as String).toList(),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  data: json['data'] as Map<String, dynamic>,
);

Map<String, dynamic> _$BounceToJson(Bounce instance) => <String, dynamic>{
  'games': instance.games,
  'slots': instance.slots,
  'tags': instance.tags,
  'data': instance.data,
};

Get _$GetFromJson(Map<String, dynamic> json) =>
    Get((json['keys'] as List<dynamic>).map((e) => e as String).toList());

Map<String, dynamic> _$GetToJson(Get instance) => <String, dynamic>{
  'keys': instance.keys,
};

Map<String, dynamic> _$SetToJson(Set instance) => <String, dynamic>{
  'cmd': instance.cmd,
  'key': instance.key,
  'default': instance.defaultValue,
  'want_reply': instance.wantReply,
  'operations': instance.operations.map((e) => e.toJson()).toList(),
};

NumericStorageOperation _$NumericStorageOperationFromJson(
  Map<String, dynamic> json,
) => NumericStorageOperation(
  $enumDecode(_$NumericStorageOperationTypeEnumMap, json['operation']),
  json['value'] as num,
);

Map<String, dynamic> _$NumericStorageOperationToJson(
  NumericStorageOperation instance,
) => <String, dynamic>{
  'operation': _$NumericStorageOperationTypeEnumMap[instance.operation]!,
  'value': instance.value,
};

const _$NumericStorageOperationTypeEnumMap = {
  NumericStorageOperationType.mul: 'mul',
  NumericStorageOperationType.pow: 'pow',
  NumericStorageOperationType.mod: 'mod',
  NumericStorageOperationType.floor: 'floor',
  NumericStorageOperationType.ceil: 'ceil',
  NumericStorageOperationType.max: 'max',
  NumericStorageOperationType.min: 'min',
};

BitwiseStorageOperation _$BitwiseStorageOperationFromJson(
  Map<String, dynamic> json,
) => BitwiseStorageOperation(
  $enumDecode(_$BitwiseStorageOperationTypeEnumMap, json['operation']),
  (json['value'] as num).toInt(),
);

Map<String, dynamic> _$BitwiseStorageOperationToJson(
  BitwiseStorageOperation instance,
) => <String, dynamic>{
  'operation': _$BitwiseStorageOperationTypeEnumMap[instance.operation]!,
  'value': instance.value,
};

const _$BitwiseStorageOperationTypeEnumMap = {
  BitwiseStorageOperationType.xor: 'xor',
  BitwiseStorageOperationType.or: 'or',
  BitwiseStorageOperationType.and: 'and',
  BitwiseStorageOperationType.leftShift: 'left_shift',
  BitwiseStorageOperationType.rightShift: 'right_shift',
};

ArrayAddStorageOperation _$ArrayAddStorageOperationFromJson(
  Map<String, dynamic> json,
) => ArrayAddStorageOperation(json['value'] as List<dynamic>);

Map<String, dynamic> _$ArrayAddStorageOperationToJson(
  ArrayAddStorageOperation instance,
) => <String, dynamic>{'value': instance.value};

DefaultStorageOperation _$DefaultStorageOperationFromJson(
  Map<String, dynamic> json,
) => DefaultStorageOperation();

Map<String, dynamic> _$DefaultStorageOperationToJson(
  DefaultStorageOperation instance,
) => <String, dynamic>{};

DynamicStorageOperation _$DynamicStorageOperationFromJson(
  Map<String, dynamic> json,
) => DynamicStorageOperation(
  $enumDecode(_$DynamicStorageOperationTypeEnumMap, json['operation']),
  json['value'],
);

Map<String, dynamic> _$DynamicStorageOperationToJson(
  DynamicStorageOperation instance,
) => <String, dynamic>{
  'operation': _$DynamicStorageOperationTypeEnumMap[instance.operation]!,
  'value': instance.value,
};

const _$DynamicStorageOperationTypeEnumMap = {
  DynamicStorageOperationType.replace: 'replace',
  DynamicStorageOperationType.setToDefault: 'default',
  DynamicStorageOperationType.remove: 'remove',
  DynamicStorageOperationType.pop: 'pop',
};

UpdateStorageOperation _$UpdateStorageOperationFromJson(
  Map<String, dynamic> json,
) => UpdateStorageOperation(json['value'] as Map<String, dynamic>);

Map<String, dynamic> _$UpdateStorageOperationToJson(
  UpdateStorageOperation instance,
) => <String, dynamic>{'value': instance.value};

SetNotify _$SetNotifyFromJson(Map<String, dynamic> json) =>
    SetNotify((json['keys'] as List<dynamic>).map((e) => e as String).toList());

Map<String, dynamic> _$SetNotifyToJson(SetNotify instance) => <String, dynamic>{
  'keys': instance.keys,
};
