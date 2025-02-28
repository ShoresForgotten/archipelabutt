library;

import 'dart:collection';

import 'package:collection/collection.dart';

interface class ArchipelagoDataStorage {
  final Map<String, ArchipelagoGame> _games;
  UnmodifiableMapView<String, ArchipelagoGame> get games =>
      UnmodifiableMapView(_games);

  void updateGame(String name, ArchipelagoGame game) {
    _games[name] = game;
  }

  ArchipelagoGame? getGame(String game) {
    return _games[game];
  }

  String? resolveItemId(String game, int id) {
    return _games[game]?.resolveItemId(id);
  }

  String? resolveLocationId(String game, int id) {
    return _games[game]?.resolveLocationId(id);
  }

  void save() {
    // Empty implementation, there's no way to store this nicely
  }

  ArchipelagoDataStorage(this._games);
}

interface class ArchipelagoGame {
  final Map<String, int> _itemNames;
  UnmodifiableMapView<String, int> get itemNames =>
      UnmodifiableMapView(_itemNames);
  final Map<String, int> _locationNames;
  UnmodifiableMapView<String, int> get locationNames =>
      UnmodifiableMapView(_locationNames);
  final String checksum;

  String? resolveItemId(int id) {
    return _itemNames.entries.firstWhereOrNull((item) => item.value == id)?.key;
  }

  String? resolveLocationId(int id) {
    return _locationNames.entries
        .firstWhereOrNull((item) => item.value == id)
        ?.key;
  }

  const ArchipelagoGame(this._itemNames, this._locationNames, this.checksum);
}
