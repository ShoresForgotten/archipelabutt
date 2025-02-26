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
class ConnectMessage extends ClientMessage {
  @JsonKey(includeToJson: true, includeFromJson: true)
  @override
  final String cmd = "Connect";
  final String? password;
  final String? game;
  final String name;
  final String uuid;
  final NetworkVersion version;
  //TODO: make this work without analysis complaining
  final _ItemsHandlingFlags? itemsHandling;
  bool? get receiveOtherWorlds => itemsHandling?.otherWorlds;
  bool? get receiveOwnWorld => itemsHandling?.ownWorld;
  bool? get receiveStartingInventory => itemsHandling?.startingInventory;
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
    receiveOtherWorlds,
    receiveOwnWorld,
    receiveStartingInventory,
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
        other.receiveOtherWorlds == receiveOtherWorlds &&
        other.receiveOwnWorld == receiveOwnWorld &&
        other.receiveStartingInventory == receiveStartingInventory &&
        ListEquality().equals(other.tags, tags) &&
        other.slotData == slotData;
  }
}

class _ItemsHandlingFlags {
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
class ConnectUpdateMessage extends ClientMessage {
  @JsonKey(includeToJson: true, includeFromJson: true)
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

  @override
  int get hashCode => Object.hash(
    receiveOtherWorlds,
    receiveOwnWorld,
    receiveStartingInventory,
    tags,
  );

  @override
  bool operator ==(Object other) {
    return other is ConnectUpdateMessage &&
        other.receiveOtherWorlds == receiveOtherWorlds &&
        other.receiveOwnWorld == receiveOwnWorld &&
        other.receiveStartingInventory == receiveStartingInventory &&
        ListEquality().equals(other.tags, tags);
  }
}

@JsonSerializable()
class SyncMessage extends ClientMessage {
  @JsonKey(includeToJson: true, includeFromJson: true)
  @override
  final String cmd = "Sync";

  SyncMessage();

  factory SyncMessage.fromJson(Map<String, dynamic> json) =>
      _$SyncMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SyncMessageToJson(this);

  @override
  int get hashCode => 0;

  @override
  bool operator ==(Object other) {
    return other is SyncMessage;
  }
}

@JsonSerializable()
class LocationChecksMessage extends ClientMessage {
  @JsonKey(includeToJson: true, includeFromJson: true)
  @override
  final String cmd = "LocationChecks";
  final List<int> locations;

  LocationChecksMessage(List<int> locations)
    : locations = List.unmodifiable(locations);

  factory LocationChecksMessage.fromJson(Map<String, dynamic> json) =>
      _$LocationChecksMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LocationChecksMessageToJson(this);

  @override
  int get hashCode => locations.hashCode;

  @override
  bool operator ==(Object other) {
    return other is LocationChecksMessage &&
        ListEquality().equals(other.locations, locations);
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LocationScoutsMessage extends ClientMessage {
  @JsonKey(includeToJson: true, includeFromJson: true)
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

  @override
  int get hashCode => Object.hash(locations, createAsHint);

  @override
  bool operator ==(Object other) {
    return other is LocationScoutsMessage &&
        ListEquality().equals(other.locations, locations) &&
        other.createAsHint == createAsHint;
  }
}

@JsonSerializable(explicitToJson: true)
class UpdateHintMessage extends ClientMessage {
  @JsonKey(includeToJson: true, includeFromJson: true)
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

  @override
  int get hashCode => Object.hash(player, location, status);

  @override
  bool operator ==(Object other) {
    return other is UpdateHintMessage &&
        other.player == player &&
        other.location == location &&
        other.status == status;
  }
}

@JsonSerializable(explicitToJson: true)
class StatusUpdateMessage extends ClientMessage {
  @JsonKey(includeToJson: true, includeFromJson: true)
  @override
  final String cmd = "StatusUpdate";
  final ClientStatus status;

  StatusUpdateMessage(this.status);

  factory StatusUpdateMessage.fromJson(Map<String, dynamic> json) =>
      _$StatusUpdateMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StatusUpdateMessageToJson(this);

  @override
  int get hashCode => status.hashCode;

  @override
  bool operator ==(Object other) {
    return other is StatusUpdateMessage && other.status == status;
  }
}

@JsonSerializable()
class SayMessage extends ClientMessage {
  @JsonKey(includeToJson: true, includeFromJson: true)
  @override
  final String cmd = "Say";
  final String text;

  SayMessage(this.text);

  factory SayMessage.fromJson(Map<String, dynamic> json) =>
      _$SayMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SayMessageToJson(this);

  @override
  int get hashCode => text.hashCode;

  @override
  bool operator ==(Object other) {
    return other is SayMessage && other.text == text;
  }
}

@JsonSerializable()
class GetDataPackageMessage extends ClientMessage {
  @JsonKey(includeToJson: true, includeFromJson: true)
  @override
  final String cmd = "GetDataPackage";
  final List<String>? games;

  GetDataPackageMessage(this.games);

  factory GetDataPackageMessage.fromJson(Map<String, dynamic> json) =>
      _$GetDataPackageMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetDataPackageMessageToJson(this);

  @override
  int get hashCode => games.hashCode;

  @override
  bool operator ==(Object other) {
    return other is GetDataPackageMessage &&
        ListEquality().equals(other.games, games);
  }
}

@JsonSerializable()
class BounceMessage extends ClientMessage {
  @JsonKey(includeToJson: true, includeFromJson: true)
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

  @override
  int get hashCode => Object.hash(games, slots, tags, data);

  @override
  bool operator ==(Object other) {
    final ListEquality le = ListEquality();
    return other is BounceMessage &&
        le.equals(other.games, games) &&
        le.equals(other.slots, slots) &&
        le.equals(other.tags, tags) &&
        MapEquality().equals(other.data, data);
  }
}

@JsonSerializable()
class GetMessage extends ClientMessage {
  @JsonKey(includeToJson: true, includeFromJson: true)
  @override
  final String cmd = "Get";
  final List<String> keys;

  GetMessage(List<String> keys) : keys = List.unmodifiable(keys);

  factory GetMessage.fromJson(Map<String, dynamic> json) =>
      _$GetMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetMessageToJson(this);

  @override
  int get hashCode => keys.hashCode;

  @override
  bool operator ==(Object other) {
    return other is GetMessage && ListEquality().equals(other.keys, keys);
  }
}

@JsonSerializable(
  explicitToJson: true,
  fieldRename: FieldRename.snake,
  createFactory: false,
)
class SetMessage extends ClientMessage {
  @JsonKey(includeToJson: true, includeFromJson: true)
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

  @override
  int get hashCode => Object.hash(key, defaultValue, wantReply, operations);

  @override
  bool operator ==(Object other) {
    return other is SetMessage &&
        other.key == key &&
        other.defaultValue == defaultValue &&
        other.wantReply == wantReply &&
        ListEquality().equals(other.operations, operations);
  }
}

sealed class DataStorageOperation {
  Map<String, dynamic> toJson();
}

@JsonSerializable(explicitToJson: true)
class NumericStorageOperation extends DataStorageOperation {
  final NumericStorageOperationType operation;
  final num value;

  NumericStorageOperation(this.operation, this.value);

  factory NumericStorageOperation.fromJson(Map<String, dynamic> json) =>
      _$NumericStorageOperationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NumericStorageOperationToJson(this);

  @override
  int get hashCode => Object.hash(operation, value);

  @override
  bool operator ==(Object other) {
    return other is NumericStorageOperation &&
        other.operation == operation &&
        other.value == value;
  }
}

@JsonEnum()
enum NumericStorageOperationType { mul, pow, mod, floor, ceil, max, min }

@JsonSerializable(explicitToJson: true)
class BitwiseStorageOperation extends DataStorageOperation {
  final BitwiseStorageOperationType operation;
  final int value;

  BitwiseStorageOperation(this.operation, this.value);

  factory BitwiseStorageOperation.fromJson(Map<String, dynamic> json) =>
      _$BitwiseStorageOperationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BitwiseStorageOperationToJson(this);

  @override
  int get hashCode => Object.hash(operation, value);

  @override
  bool operator ==(Object other) {
    return other is BitwiseStorageOperation &&
        other.operation == operation &&
        other.value == value;
  }
}

@JsonEnum(fieldRename: FieldRename.snake)
enum BitwiseStorageOperationType { xor, or, and, leftShift, rightShift }

@JsonSerializable(explicitToJson: true)
class ArrayAddStorageOperation extends DataStorageOperation {
  final String operation = "add";
  final List<dynamic> value;

  ArrayAddStorageOperation(List<dynamic> value)
    : value = List.unmodifiable(value);

  factory ArrayAddStorageOperation.fromJson(Map<String, dynamic> json) =>
      _$ArrayAddStorageOperationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArrayAddStorageOperationToJson(this);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    return other is ArrayAddStorageOperation &&
        ListEquality().equals(other.value, value);
  }
}

@JsonSerializable(explicitToJson: true)
class DefaultStorageOperation extends DataStorageOperation {
  final String operation = "default";
  final dynamic value = 0;

  DefaultStorageOperation();

  factory DefaultStorageOperation.fromJson(Map<String, dynamic> json) =>
      _$DefaultStorageOperationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DefaultStorageOperationToJson(this);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    return other is DefaultStorageOperation && other.value == value;
  }
}

@JsonSerializable(explicitToJson: true)
class DynamicStorageOperation extends DataStorageOperation {
  final DynamicStorageOperationType operation;
  final dynamic value;

  DynamicStorageOperation(this.operation, this.value);

  factory DynamicStorageOperation.fromJson(Map<String, dynamic> json) =>
      _$DynamicStorageOperationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DynamicStorageOperationToJson(this);

  @override
  int get hashCode => Object.hash(operation, value);

  @override
  bool operator ==(Object other) {
    return other is DynamicStorageOperation && other.value == value;
  }
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
class UpdateStorageOperation extends DataStorageOperation {
  final String operation = 'update';
  final Map<dynamic, dynamic> value;

  UpdateStorageOperation(Map<dynamic, dynamic> value)
    : value = Map.unmodifiable(value);

  factory UpdateStorageOperation.fromJson(Map<String, dynamic> json) =>
      _$UpdateStorageOperationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UpdateStorageOperationToJson(this);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    return other is UpdateStorageOperation &&
        MapEquality().equals(other.value, value);
  }
}

@JsonSerializable()
class SetNotifyMessage extends ClientMessage {
  @JsonKey(includeToJson: true, includeFromJson: true)
  @override
  final String cmd = 'SetNotify';
  final List<String> keys;

  SetNotifyMessage(List<String> keys) : keys = List.unmodifiable(keys);

  factory SetNotifyMessage.fromJson(Map<String, dynamic> json) =>
      _$SetNotifyMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SetNotifyMessageToJson(this);

  @override
  int get hashCode => keys.hashCode;

  @override
  bool operator ==(Object other) {
    return other is SetNotifyMessage && ListEquality().equals(other.keys, keys);
  }
}
