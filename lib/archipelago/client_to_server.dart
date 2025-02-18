library;

import 'package:json_annotation/json_annotation.dart';

import 'protocol_types.dart';

part 'client_to_server.g.dart';

sealed class ClientMessage {
  abstract final String cmd;
  Map<String, dynamic> toJson();
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
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
    this.itemsHandling,
    this.tags,
    this.slotData,
  );

  factory Connect.fromJson(Map<String, dynamic> json) =>
      _$ConnectFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectToJson(this);
}

final class ItemsHandlingFlags {
  final bool otherWorlds;
  final bool ownWorld;
  final bool startingInventory;

  ItemsHandlingFlags(this.otherWorlds, this.ownWorld, this.startingInventory);

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
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
final class ConnectUpdate extends ClientMessage {
  @override
  final String cmd = "ConnectUpdate";
  final ItemsHandlingFlags itemsHandling;
  final List<String> tags;

  ConnectUpdate(this.itemsHandling, this.tags);

  factory ConnectUpdate.fromJson(Map<String, dynamic> json) =>
      _$ConnectUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectUpdateToJson(this);
}

@JsonSerializable()
final class Sync extends ClientMessage {
  @override
  final String cmd = "Sync";

  Sync();

  factory Sync.fromJson(Map<String, dynamic> json) => _$SyncFromJson(json);

  Map<String, dynamic> toJson() => _$SyncToJson(this);
}

@JsonSerializable()
final class LocationChecks extends ClientMessage {
  @override
  final String cmd = "LocationChecks";
  final List<int> locations;

  LocationChecks(this.locations);

  factory LocationChecks.fromJson(Map<String, dynamic> json) =>
      _$LocationChecksFromJson(json);

  Map<String, dynamic> toJson() => _$LocationChecksToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
final class LocationScouts extends ClientMessage {
  @override
  final String cmd = "LocationScouts";
  final List<int> locations;
  final int createAsHint;

  LocationScouts(this.locations, this.createAsHint);

  bool get createHints => createAsHint != 0;

  bool get newHintsOnly => createAsHint == 2;

  factory LocationScouts.fromJson(Map<String, dynamic> json) =>
      _$LocationScoutsFromJson(json);

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

  Map<String, dynamic> toJson() => _$StatusUpdateToJson(this);
}

@JsonSerializable()
final class Say extends ClientMessage {
  @override
  final String cmd = "Say";
  final String text;

  Say(this.text);

  factory Say.fromJson(Map<String, dynamic> json) => _$SayFromJson(json);

  Map<String, dynamic> toJson() => _$SayToJson(this);
}

@JsonSerializable()
final class GetDataPackage extends ClientMessage {
  @override
  final String cmd = "GetDataPackage";
  final List<String>? games;

  GetDataPackage(this.games);

  factory GetDataPackage.fromJson(Map<String, dynamic> json) =>
      _$GetDataPackageFromJson(json);

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

  Bounce({this.games, this.slots, this.tags, required this.data});

  factory Bounce.fromJson(Map<String, dynamic> json) => _$BounceFromJson(json);

  Map<String, dynamic> toJson() => _$BounceToJson(this);
}

@JsonSerializable()
final class Get extends ClientMessage {
  @override
  final String cmd = "Get";
  final List<String> keys;

  Get(this.keys);

  factory Get.fromJson(Map<String, dynamic> json) => _$GetFromJson(json);

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

  Set(this.key, this.defaultValue, this.wantReply, this.operations);

  //factory Set.fromJson(Map<String, dynamic> json) => _$SetFromJson(json);

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

  ArrayAddStorageOperation(this.value);

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

  UpdateStorageOperation(this.value);

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

  SetNotify(this.keys);

  factory SetNotify.fromJson(Map<String, dynamic> json) =>
      _$SetNotifyFromJson(json);

  Map<String, dynamic> toJson() => _$SetNotifyToJson(this);
}
