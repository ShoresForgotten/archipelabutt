// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protocol_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkPlayer _$NetworkPlayerFromJson(Map<String, dynamic> json) =>
    NetworkPlayer(
      (json['team'] as num).toInt(),
      (json['slot'] as num).toInt(),
      json['alias'] as String,
      json['name'] as String,
    );

Map<String, dynamic> _$NetworkPlayerToJson(NetworkPlayer instance) =>
    <String, dynamic>{
      'team': instance.team,
      'slot': instance.slot,
      'alias': instance.alias,
      'name': instance.name,
    };

NetworkItem _$NetworkItemFromJson(Map<String, dynamic> json) => NetworkItem(
  (json['item'] as num).toInt(),
  (json['location'] as num).toInt(),
  (json['player'] as num).toInt(),
  NetworkItemFlags.fromJson((json['flags'] as num).toInt()),
);

Map<String, dynamic> _$NetworkItemToJson(NetworkItem instance) =>
    <String, dynamic>{
      'item': instance.item,
      'location': instance.location,
      'player': instance.player,
      'flags': instance.flags.toJson(),
    };

TextMessagePart _$TextMessagePartFromJson(Map<String, dynamic> json) =>
    TextMessagePart(json['text'] as String);

Map<String, dynamic> _$TextMessagePartToJson(TextMessagePart instance) =>
    <String, dynamic>{'text': instance.text};

PlayerIDMessagePart _$PlayerIDMessagePartFromJson(Map<String, dynamic> json) =>
    PlayerIDMessagePart(json['text'] as String);

Map<String, dynamic> _$PlayerIDMessagePartToJson(
  PlayerIDMessagePart instance,
) => <String, dynamic>{'text': instance.text};

PlayerNameMessagePart _$PlayerNameMessagePartFromJson(
  Map<String, dynamic> json,
) => PlayerNameMessagePart(json['text'] as String);

Map<String, dynamic> _$PlayerNameMessagePartToJson(
  PlayerNameMessagePart instance,
) => <String, dynamic>{'text': instance.text};

ItemIDMessagePart _$ItemIDMessagePartFromJson(Map<String, dynamic> json) =>
    ItemIDMessagePart(
      json['text'] as String,
      NetworkItemFlags.fromJson((json['flags'] as num).toInt()),
      (json['player'] as num).toInt(),
    );

Map<String, dynamic> _$ItemIDMessagePartToJson(ItemIDMessagePart instance) =>
    <String, dynamic>{
      'text': instance.text,
      'flags': instance.flags.toJson(),
      'player': instance.player,
    };

ItemNameMessagePart _$ItemNameMessagePartFromJson(Map<String, dynamic> json) =>
    ItemNameMessagePart(
      json['text'] as String,
      NetworkItemFlags.fromJson((json['flags'] as num).toInt()),
      (json['player'] as num).toInt(),
    );

Map<String, dynamic> _$ItemNameMessagePartToJson(
  ItemNameMessagePart instance,
) => <String, dynamic>{
  'text': instance.text,
  'flags': instance.flags.toJson(),
  'player': instance.player,
};

LocationIDMessagePart _$LocationIDMessagePartFromJson(
  Map<String, dynamic> json,
) => LocationIDMessagePart(
  json['text'] as String,
  (json['player'] as num).toInt(),
);

Map<String, dynamic> _$LocationIDMessagePartToJson(
  LocationIDMessagePart instance,
) => <String, dynamic>{'text': instance.text, 'player': instance.player};

LocationNameMessagePart _$LocationNameMessagePartFromJson(
  Map<String, dynamic> json,
) => LocationNameMessagePart(
  json['text'] as String,
  (json['player'] as num).toInt(),
);

Map<String, dynamic> _$LocationNameMessagePartToJson(
  LocationNameMessagePart instance,
) => <String, dynamic>{'text': instance.text, 'player': instance.player};

EntranceNameMessagePart _$EntranceNameMessagePartFromJson(
  Map<String, dynamic> json,
) => EntranceNameMessagePart(json['text'] as String);

Map<String, dynamic> _$EntranceNameMessagePartToJson(
  EntranceNameMessagePart instance,
) => <String, dynamic>{'text': instance.text};

HintStatusMessagePart _$HintStatusMessagePartFromJson(
  Map<String, dynamic> json,
) => HintStatusMessagePart(
  json['text'] as String,
  $enumDecode(_$HintStatusEnumMap, json['status']),
);

Map<String, dynamic> _$HintStatusMessagePartToJson(
  HintStatusMessagePart instance,
) => <String, dynamic>{
  'text': instance.text,
  'status': _$HintStatusEnumMap[instance.status]!,
};

const _$HintStatusEnumMap = {
  HintStatus.unspecified: 0,
  HintStatus.noPriority: 10,
  HintStatus.avoid: 20,
  HintStatus.priority: 30,
  HintStatus.found: 40,
};

ColorMessagePart _$ColorMessagePartFromJson(Map<String, dynamic> json) =>
    ColorMessagePart(
      json['text'] as String,
      $enumDecode(_$ConsoleColorEnumMap, json['color']),
    );

Map<String, dynamic> _$ColorMessagePartToJson(ColorMessagePart instance) =>
    <String, dynamic>{
      'text': instance.text,
      'color': _$ConsoleColorEnumMap[instance.color]!,
    };

const _$ConsoleColorEnumMap = {
  ConsoleColor.bold: 'bold',
  ConsoleColor.underline: 'underline',
  ConsoleColor.black: 'black',
  ConsoleColor.red: 'red',
  ConsoleColor.green: 'green',
  ConsoleColor.yellow: 'yellow',
  ConsoleColor.blue: 'blue',
  ConsoleColor.magenta: 'magenta',
  ConsoleColor.cyan: 'cyan',
  ConsoleColor.white: 'white',
  ConsoleColor.blackBackground: 'black_bg',
  ConsoleColor.redBackground: 'red_bg',
  ConsoleColor.greenBackground: 'green_bg',
  ConsoleColor.yellowBackground: 'yellow_bg',
  ConsoleColor.blueBackground: 'blue_bg',
  ConsoleColor.magentaBackground: 'magenta_bg',
  ConsoleColor.cyanBackground: 'cyan_bg',
  ConsoleColor.whiteBackground: 'white_bg',
};

NetworkVersion _$NetworkVersionFromJson(Map<String, dynamic> json) =>
    NetworkVersion(
      (json['major'] as num).toInt(),
      (json['minor'] as num).toInt(),
      (json['build'] as num).toInt(),
    );

Map<String, dynamic> _$NetworkVersionToJson(NetworkVersion instance) =>
    <String, dynamic>{
      'major': instance.major,
      'minor': instance.minor,
      'build': instance.build,
    };

NetworkSlot _$NetworkSlotFromJson(Map<String, dynamic> json) => NetworkSlot(
  json['name'] as String,
  json['game'] as String,
  SlotType.fromJson((json['type'] as num).toInt()),
  (json['groupMembers'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$NetworkSlotToJson(NetworkSlot instance) =>
    <String, dynamic>{
      'name': instance.name,
      'game': instance.game,
      'type': instance.type.toJson(),
      'groupMembers': instance.groupMembers,
    };

Hint _$HintFromJson(Map<String, dynamic> json) => Hint(
  (json['receivingPlayer'] as num).toInt(),
  (json['findingPlayer'] as num).toInt(),
  (json['location'] as num).toInt(),
  (json['item'] as num).toInt(),
  json['found'] as bool,
  entrance: json['entrance'] as String? ?? "",
  flags:
      json['flags'] == null
          ? NetworkItemFlags.emptyFlags
          : NetworkItemFlags.fromJson((json['flags'] as num).toInt()),
  status:
      $enumDecodeNullable(_$HintStatusEnumMap, json['status']) ??
      HintStatus.unspecified,
);

Map<String, dynamic> _$HintToJson(Hint instance) => <String, dynamic>{
  'receivingPlayer': instance.receivingPlayer,
  'findingPlayer': instance.findingPlayer,
  'location': instance.location,
  'item': instance.item,
  'found': instance.found,
  'entrance': instance.entrance,
  'flags': instance.flags.toJson(),
  'status': _$HintStatusEnumMap[instance.status]!,
};
