library;

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

import 'protocol_types.dart';

part 'client_to_server.g.dart';

sealed class ClientMessage {
  abstract final String cmd;
  Map<String, dynamic> toJson();
}

@JsonSerializable(
  explicitToJson: true,
  fieldRename: FieldRename.snake,
  constructor: '_jsonConstructor',
)
final class Connect extends ClientMessage {
  @override
  final String cmd = "Connect";
  final String? password;
  final String? game;
  final String name;
  final String uuid;
  final NetworkVersion version;
  final ItemsHandlingFlags? itemsHandling;
  final List<String> tags;
  final bool slotData;

  Connect(
    this.password,
    this.game,
    this.name,
    this.uuid,
    this.version,
    bool receiveOtherWorld,
    bool receiveOwnWorld,
    bool receiveStartingInventory,
    List<String> tags,
    this.slotData,
  ) : tags = List.unmodifiable(tags),
      itemsHandling = ItemsHandlingFlags(
        receiveOtherWorld,
        receiveOwnWorld,
        receiveStartingInventory,
      );

  Connect._jsonConstructor(
    this.password,
    this.game,
    this.name,
    this.uuid,
    this.version,
    this.itemsHandling,
    this.tags,
    this.slotData,
  );

  factory Connect.fromJson(Map<String, dynamic> json) =>
      _$ConnectFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ConnectToJson(this);

  @override
  int get hashCode => Object.hash(
    password,
    game,
    name,
    uuid,
    version,
    itemsHandling,
    tags,
    slotData,
  );

  @override
  bool operator ==(Object other) {
    return other is Connect &&
        other.password == password &&
        other.game == game &&
        other.name == name &&
        other.uuid == uuid &&
        other.version == version &&
        other.itemsHandling == itemsHandling &&
        ListEquality().equals(other.tags, tags) &&
        other.slotData == slotData;
  }
}

final class ItemsHandlingFlags {
  final bool otherWorlds;
  final bool ownWorld;
  final bool startingInventory;

  const ItemsHandlingFlags(
    this.otherWorlds,
    this.ownWorld,
    this.startingInventory,
  );

  factory ItemsHandlingFlags.fromJson(int raw) {
    bool otherWorlds = false;
    bool ownWorld = false;
    bool startingInventory = false;
    if (raw & 1 == 1) {
      otherWorlds = true;
    } else {
      otherWorlds = false;
    }
    if ((raw & 2 == 2 || raw & 4 == 4) && !otherWorlds) {
      throw 'Invalid items_handling flags';
    }
    if (raw & 2 == 2) {
      ownWorld = true;
    }
    if (raw & 4 == 4) {
      startingInventory = true;
    }
    return ItemsHandlingFlags(otherWorlds, ownWorld, startingInventory);
  }

  int toJson() {
    int flags = 0;
    if (otherWorlds) {
      flags += 1;
    }
    if (ownWorld) {
      flags += 2;
    }
    if (startingInventory) {
      flags += 4;
    }
    return flags;
  }

  @override
  int get hashCode => Object.hash(otherWorlds, ownWorld, startingInventory);

  @override
  bool operator ==(Object other) {
    return other is ItemsHandlingFlags &&
        other.otherWorlds == otherWorlds &&
        other.ownWorld == ownWorld &&
        other.startingInventory == startingInventory;
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
final class ConnectUpdate extends ClientMessage {
  @override
  final String cmd = "ConnectUpdate";
  final ItemsHandlingFlags itemsHandling;
  final List<String> tags;

  ConnectUpdate(this.itemsHandling, List<String> tags)
    : tags = List.unmodifiable(tags);

  factory ConnectUpdate.fromJson(Map<String, dynamic> json) =>
      _$ConnectUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ConnectUpdateToJson(this);
}

@JsonSerializable()
final class Sync extends ClientMessage {
  @override
  final String cmd = "Sync";

  Sync();

  factory Sync.fromJson(Map<String, dynamic> json) => _$SyncFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SyncToJson(this);
}

@JsonSerializable()
final class LocationChecks extends ClientMessage {
  @override
  final String cmd = "LocationChecks";
  final List<int> locations;

  LocationChecks(List<int> locations)
    : locations = List.unmodifiable(locations);

  factory LocationChecks.fromJson(Map<String, dynamic> json) =>
      _$LocationChecksFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LocationChecksToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
final class LocationScouts extends ClientMessage {
  @override
  final String cmd = "LocationScouts";
  final List<int> locations;
  final int createAsHint;

  LocationScouts(List<int> locations, this.createAsHint)
    : locations = List.unmodifiable(locations);

  bool get createHints => createAsHint != 0;

  bool get newHintsOnly => createAsHint == 2;

  factory LocationScouts.fromJson(Map<String, dynamic> json) =>
      _$LocationScoutsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LocationScoutsToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class UpdateHint extends ClientMessage {
  @override
  final String cmd = "UpdateHint";
  final int player;
  final int location;
  final HintStatus? status;

  UpdateHint(this.player, this.location, [this.status]);

  factory UpdateHint.fromJson(Map<String, dynamic> json) =>
      _$UpdateHintFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UpdateHintToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class StatusUpdate extends ClientMessage {
  @override
  final String cmd = "StatusUpdate";
  final ClientStatus status;

  StatusUpdate(this.status);

  factory StatusUpdate.fromJson(Map<String, dynamic> json) =>
      _$StatusUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StatusUpdateToJson(this);
}

@JsonSerializable()
final class Say extends ClientMessage {
  @override
  final String cmd = "Say";
  final String text;

  Say(this.text);

  factory Say.fromJson(Map<String, dynamic> json) => _$SayFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SayToJson(this);
}

@JsonSerializable()
final class GetDataPackage extends ClientMessage {
  @override
  final String cmd = "GetDataPackage";
  final List<String>? games;

  GetDataPackage(List<String> games) : games = List.unmodifiable(games);

  factory GetDataPackage.fromJson(Map<String, dynamic> json) =>
      _$GetDataPackageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetDataPackageToJson(this);
}

@JsonSerializable()
final class Bounce extends ClientMessage {
  @override
  final String cmd = "Bounce";
  final List<String>? games;
  final List<String>? slots;
  final List<String>? tags;
  final Map<dynamic, dynamic> data;

  Bounce._({this.games, this.slots, this.tags, required this.data});

  factory Bounce({
    List<String>? games,
    List<String>? slots,
    List<String>? tags,
    required Map<dynamic, dynamic> data,
  }) {
    if (games != null) games = List.unmodifiable(games);
    if (slots != null) slots = List.unmodifiable(slots);
    if (tags != null) tags = List.unmodifiable(tags);

    return Bounce._(
      games: games,
      slots: slots,
      tags: tags,
      data: Map.unmodifiable(data),
    );
  }

  factory Bounce.fromJson(Map<String, dynamic> json) => _$BounceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BounceToJson(this);
}

@JsonSerializable()
final class Get extends ClientMessage {
  @override
  final String cmd = "Get";
  final List<String> keys;

  Get(List<String> keys) : keys = List.unmodifiable(keys);

  factory Get.fromJson(Map<String, dynamic> json) => _$GetFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetToJson(this);
}

@JsonSerializable(
  explicitToJson: true,
  fieldRename: FieldRename.snake,
  createFactory: false,
)
final class Set extends ClientMessage {
  @override
  final String cmd = "Set";
  final String key;
  @JsonKey(name: 'default')
  final dynamic defaultValue;
  final bool wantReply;
  final List<DataStorageOperation> operations;

  Set(
    this.key,
    this.defaultValue,
    this.wantReply,
    List<DataStorageOperation> operations,
  ) : operations = List.unmodifiable(operations);

  //factory Set.fromJson(Map<String, dynamic> json) => _$SetFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SetToJson(this);
}

sealed class DataStorageOperation {
  Map<String, dynamic> toJson();
}

@JsonSerializable(explicitToJson: true)
final class NumericStorageOperation extends DataStorageOperation {
  final NumericStorageOperationType operation;
  final num value;

  NumericStorageOperation(this.operation, this.value);

  factory NumericStorageOperation.fromJson(Map<String, dynamic> json) =>
      _$NumericStorageOperationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NumericStorageOperationToJson(this);
}

@JsonEnum()
enum NumericStorageOperationType { mul, pow, mod, floor, ceil, max, min }

@JsonSerializable(explicitToJson: true)
final class BitwiseStorageOperation extends DataStorageOperation {
  final BitwiseStorageOperationType operation;
  final int value;

  BitwiseStorageOperation(this.operation, this.value);

  factory BitwiseStorageOperation.fromJson(Map<String, dynamic> json) =>
      _$BitwiseStorageOperationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BitwiseStorageOperationToJson(this);
}

@JsonEnum(fieldRename: FieldRename.snake)
enum BitwiseStorageOperationType { xor, or, and, leftShift, rightShift }

@JsonSerializable(explicitToJson: true)
final class ArrayAddStorageOperation extends DataStorageOperation {
  final String operation = "add";
  final List<dynamic> value;

  ArrayAddStorageOperation(List<dynamic> value)
    : value = List.unmodifiable(value);

  factory ArrayAddStorageOperation.fromJson(Map<String, dynamic> json) =>
      _$ArrayAddStorageOperationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArrayAddStorageOperationToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class DefaultStorageOperation extends DataStorageOperation {
  final String operation = "default";
  final dynamic value = 0;

  DefaultStorageOperation();

  factory DefaultStorageOperation.fromJson(Map<String, dynamic> json) =>
      _$DefaultStorageOperationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DefaultStorageOperationToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class DynamicStorageOperation extends DataStorageOperation {
  final DynamicStorageOperationType operation;
  final dynamic value;

  DynamicStorageOperation(this.operation, this.value);

  factory DynamicStorageOperation.fromJson(Map<String, dynamic> json) =>
      _$DynamicStorageOperationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DynamicStorageOperationToJson(this);
}

@JsonEnum(valueField: 'operationName')
enum DynamicStorageOperationType {
  replace('replace'),
  setToDefault('default'),
  remove('remove'),
  pop('pop');

  final String operationName;

  const DynamicStorageOperationType(this.operationName);
}

@JsonSerializable()
final class UpdateStorageOperation extends DataStorageOperation {
  final String operation = 'update';
  final Map<dynamic, dynamic> value;

  UpdateStorageOperation(Map<dynamic, dynamic> value)
    : value = Map.unmodifiable(value);

  factory UpdateStorageOperation.fromJson(Map<String, dynamic> json) =>
      _$UpdateStorageOperationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UpdateStorageOperationToJson(this);
}

@JsonSerializable()
final class SetNotify extends ClientMessage {
  @override
  final String cmd = 'SetNotify';
  final List<String> keys;

  SetNotify(List<String> keys) : keys = List.unmodifiable(keys);

  factory SetNotify.fromJson(Map<String, dynamic> json) =>
      _$SetNotifyFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SetNotifyToJson(this);
}
