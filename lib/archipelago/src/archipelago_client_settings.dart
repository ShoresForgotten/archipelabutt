library;

/// Application-facing connection settings.
class ArchipelagoClientSettings {
  final String name;
  final String uuid;
  final String? game;
  final String? password;
  final bool receiveSlotData;
  List<String> tags;
  bool _receiveOtherWorlds;
  bool get receiveOtherWorlds => _receiveOtherWorlds;
  bool _receiveOwnWorld;
  bool get receiveOwnWorld => _receiveOwnWorld;
  bool _receiveStartingInventory;
  bool get receiveStartingInventory => _receiveStartingInventory;

  ArchipelagoClientSettings._(
    this.name,
    this.uuid,
    this.game,
    this.password,
    this.tags,
    this._receiveOtherWorlds,
    this._receiveOwnWorld,
    this._receiveStartingInventory,
    this.receiveSlotData,
  );

  void setItemHandlingFlags(bool other, bool own, bool starting) {
    if ((own || starting) && !other) {
      Error();
    }
    _receiveOtherWorlds = other;
    _receiveOwnWorld = own;
    _receiveStartingInventory = starting;
  }

  factory ArchipelagoClientSettings({
    required String name,
    required String uuid,
    String? password,
    String? game,
    List<String>? tags,
    bool receiveOtherWorlds = false,
    bool receiveOwnWorld = false,
    bool receiveStartingInventory = false,
    bool receiveSlotData = false,
  }) {
    if (game == null &&
        (tags == null ||
            !tags.contains('HintGame') ||
            !tags.contains('Tracker') ||
            !tags.contains('TextOnly'))) {
      throw Error();
    }
    if ((receiveOwnWorld || receiveStartingInventory) && !receiveOtherWorlds) {
      throw Error();
    }
    return ArchipelagoClientSettings._(
      name,
      uuid,
      game,
      password,
      tags ?? [],
      receiveOtherWorlds,
      receiveOwnWorld,
      receiveStartingInventory,
      receiveSlotData,
    );
  }
}
