/// All the messages that can be sent from the client to the server.
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
final class ConnectMessage extends ClientMessage {
  @override
  final String cmd = "Connect";
  final String? password;
  final String? game;
  final String name;
  final String uuid;
  final NetworkVersion version;
  final _ItemsHandlingFlags? itemsHandling;
  final List<String> tags;
  final bool slotData;

  ConnectMessage(
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
      itemsHandling = _ItemsHandlingFlags(
        receiveOtherWorld,
        receiveOwnWorld,
        receiveStartingInventory,
      );

  ConnectMessage._jsonConstructor(
    this.password,
    this.game,
    this.name,
    this.uuid,
    this.version,
    this.itemsHandling,
    this.tags,
    this.slotData,
  );

  factory ConnectMessage.fromJson(Map<String, dynamic> json) =>
      _$ConnectMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ConnectMessageToJson(this);

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
    return other is ConnectMessage &&
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

final class _ItemsHandlingFlags {
  final bool otherWorlds;
  final bool ownWorld;
  final bool startingInventory;

  const _ItemsHandlingFlags(
    this.otherWorlds,
    this.ownWorld,
    this.startingInventory,
  );

  factory _ItemsHandlingFlags.fromJson(int raw) {
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
    return _ItemsHandlingFlags(otherWorlds, ownWorld, startingInventory);
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
    return other is _ItemsHandlingFlags &&
        other.otherWorlds == otherWorlds &&
        other.ownWorld == ownWorld &&
        other.startingInventory == startingInventory;
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
final class ConnectUpdateMessage extends ClientMessage {
  @override
  final String cmd = "ConnectUpdate";
  final _ItemsHandlingFlags _itemsHandling;
  bool get receiveOtherWorlds => _itemsHandling.otherWorlds;
  bool get receiveOwnWorld => _itemsHandling.ownWorld;
  bool get receiveStartingInventory => _itemsHandling.startingInventory;
  final List<String> tags;

  ConnectUpdateMessage(
    bool receiveOtherWorlds,
    bool receiveOwnWorld,
    bool receiveStartingInventory,
    List<String> tags,
  ) : tags = List.unmodifiable(tags),
      _itemsHandling = _ItemsHandlingFlags(
        receiveOtherWorlds,
        receiveOwnWorld,
        receiveStartingInventory,
      );

  factory ConnectUpdateMessage.fromJson(Map<String, dynamic> json) =>
      _$ConnectUpdateMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ConnectUpdateMessageToJson(this);
}

@JsonSerializable()
final class SyncMessage extends ClientMessage {
  @override
  final String cmd = "Sync";

  SyncMessage();

  factory SyncMessage.fromJson(Map<String, dynamic> json) =>
      _$SyncMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SyncMessageToJson(this);
}

@JsonSerializable()
final class LocationChecksMessage extends ClientMessage {
  @override
  final String cmd = "LocationChecks";
  final List<int> locations;

  LocationChecksMessage(List<int> locations)
    : locations = List.unmodifiable(locations);

  factory LocationChecksMessage.fromJson(Map<String, dynamic> json) =>
      _$LocationChecksMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LocationChecksMessageToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
final class LocationScoutsMessage extends ClientMessage {
  @override
  final String cmd = "LocationScouts";
  final List<int> locations;
  final int createAsHint;

  LocationScoutsMessage(List<int> locations, this.createAsHint)
    : locations = List.unmodifiable(locations);

  bool get createHints => createAsHint != 0;

  bool get newHintsOnly => createAsHint == 2;

  factory LocationScoutsMessage.fromJson(Map<String, dynamic> json) =>
      _$LocationScoutsMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LocationScoutsMessageToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class UpdateHintMessage extends ClientMessage {
  @override
  final String cmd = "UpdateHint";
  final int player;
  final int location;
  final HintStatus? status;

  UpdateHintMessage(this.player, this.location, [this.status]);

  factory UpdateHintMessage.fromJson(Map<String, dynamic> json) =>
      _$UpdateHintMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UpdateHintMessageToJson(this);
}

@JsonSerializable(explicitToJson: true)
final class StatusUpdateMessage extends ClientMessage {
  @override
  final String cmd = "StatusUpdate";
  final ClientStatus status;

  StatusUpdateMessage(this.status);

  factory StatusUpdateMessage.fromJson(Map<String, dynamic> json) =>
      _$StatusUpdateMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StatusUpdateMessageToJson(this);
}

@JsonSerializable()
final class SayMessage extends ClientMessage {
  @override
  final String cmd = "Say";
  final String text;

  SayMessage(this.text);

  factory SayMessage.fromJson(Map<String, dynamic> json) =>
      _$SayMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SayMessageToJson(this);
}

@JsonSerializable()
final class GetDataPackageMessage extends ClientMessage {
  @override
  final String cmd = "GetDataPackage";
  final List<String>? games;

  GetDataPackageMessage(this.games);

  factory GetDataPackageMessage.fromJson(Map<String, dynamic> json) =>
      _$GetDataPackageMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetDataPackageMessageToJson(this);
}

@JsonSerializable()
final class BounceMessage extends ClientMessage {
  @override
  final String cmd = "Bounce";
  final List<String>? games;
  final List<int>? slots;
  final List<String>? tags;
  final Map<dynamic, dynamic> data;

  BounceMessage._({this.games, this.slots, this.tags, required this.data});

  factory BounceMessage({
    List<String>? games,
    List<int>? slots,
    List<String>? tags,
    required Map<dynamic, dynamic> data,
  }) {
    if (games != null) games = List.unmodifiable(games);
    if (slots != null) slots = List.unmodifiable(slots);
    if (tags != null) tags = List.unmodifiable(tags);

    return BounceMessage._(
      games: games,
      slots: slots,
      tags: tags,
      data: Map.unmodifiable(data),
    );
  }

  factory BounceMessage.fromJson(Map<String, dynamic> json) =>
      _$BounceMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BounceMessageToJson(this);
}

@JsonSerializable()
final class GetMessage extends ClientMessage {
  @override
  final String cmd = "Get";
  final List<String> keys;

  GetMessage(List<String> keys) : keys = List.unmodifiable(keys);

  factory GetMessage.fromJson(Map<String, dynamic> json) =>
      _$GetMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetMessageToJson(this);
}

@JsonSerializable(
  explicitToJson: true,
  fieldRename: FieldRename.snake,
  createFactory: false,
)
final class SetMessage extends ClientMessage {
  @override
  final String cmd = "Set";
  final String key;
  @JsonKey(name: 'default')
  final dynamic defaultValue;
  final bool wantReply;
  final List<DataStorageOperation> operations;

  SetMessage._(this.key, this.defaultValue, this.wantReply, this.operations);

  factory SetMessage(
    key,
    defaultValue,
    wantReply,
    List<DataStorageOperation> operations,
  ) {
    final List<DataStorageOperation> ops = List.unmodifiable(operations);
    if (key.startsWith('_read_')) Error();
    return SetMessage._(key, defaultValue, wantReply, ops);
  }

  //factory Set.fromJson(Map<String, dynamic> json) => _$SetFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SetMessageToJson(this);
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
final class SetNotifyMessage extends ClientMessage {
  @override
  final String cmd = 'SetNotify';
  final List<String> keys;

  SetNotifyMessage(List<String> keys) : keys = List.unmodifiable(keys);

  factory SetNotifyMessage.fromJson(Map<String, dynamic> json) =>
      _$SetNotifyMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SetNotifyMessageToJson(this);
}
