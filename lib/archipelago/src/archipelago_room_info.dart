library;

import 'dart:collection';

import 'protocol_types.dart';

final class ArchipelagoRoomInfo {
  // In Connected
  List<NetworkPlayer> _players;
  UnmodifiableListView<NetworkPlayer> get players =>
      UnmodifiableListView(_players);
  set players(List<NetworkPlayer> updated) => _players = updated;
  int _team;
  int get team => _team;
  int _slot;
  int get slot => _slot;
  Map<String, dynamic>? _slotData;
  Map<String, dynamic>? get slotData => _slotData;
  Map<int, NetworkSlot> _slotInfo;
  Map<int, NetworkSlot> get slotInfo => _slotInfo;
  int _hintPoints;
  int get hintPoints => _hintPoints;
  // This is handled via diffs, so it's final but mutable.
  final Set<int> _checkedLocations;
  UnmodifiableSetView<int> get checkedLocations =>
      UnmodifiableSetView(_checkedLocations);
  // This won't be sent in RoomUpdate messages
  final Set<int> _missingLocations;
  UnmodifiableSetView<int> get missingLocations =>
      UnmodifiableSetView(_missingLocations);

  // In RoomInfo
  List<String> _tags;
  UnmodifiableListView<String> get tags => UnmodifiableListView(_tags);
  bool _password;
  bool get password => _password;
  PermissionsDict _permissions;
  Permission get releasePermission => _permissions.release;
  Permission get collectPermission => _permissions.collect;
  Permission get remainingPermission => _permissions.remaining;
  int _hintCost;
  int get hintCost => _hintCost;
  int _locationCheckPoints;
  int get locationCheckPoints => _locationCheckPoints;
  List<String> _games;
  UnmodifiableListView<String> get games => UnmodifiableListView(_games);
  Map<String, String> _datapackageChecksums;
  UnmodifiableMapView<String, String> get datapackageChecksums =>
      UnmodifiableMapView(_datapackageChecksums);
  String _seedName;
  String get seedName => _seedName;
  DateTime _time;
  DateTime get time => _time;

  ArchipelagoRoomInfo(
    this._players,
    this._team,
    this._slot,
    this._slotData,
    this._slotInfo,
    this._hintPoints,
    List<int> checkedLocations,
    List<int> missingLocations,
    this._tags,
    this._password,
    this._permissions,
    this._hintCost,
    this._locationCheckPoints,
    this._games,
    this._datapackageChecksums,
    this._seedName,
    this._time,
  ) : _checkedLocations = checkedLocations.fold<Set<int>>(<int>{}, (set, x) {
        set.add(x);
        return set;
      }),
      _missingLocations = missingLocations.fold<Set<int>>(<int>{}, (set, x) {
        set.add(x);
        return set;
      });

  void _updateCheckedLocations(List<int> newLocations) {
    for (var location in newLocations) {
      _checkedLocations.add(location);
      _missingLocations.remove(location);
    }
  }

  void updateRoomInfo({
    int? team,
    int? slot,
    List<NetworkPlayer>? players,
    List<int>? checkedLocations,
    Map<String, dynamic>? slotData,
    Map<int, NetworkSlot>? slotInfo,
    int? hintPoints,
    List<String>? tags,
    bool? password,
    PermissionsDict? permissions,
    int? hintCost,
    int? locationCheckPoints,
    List<String>? games,
    Map<String, String>? datapackageChecksums,
    String? seedName,
    DateTime? time,
  }) {
    if (team != null) _team = team;
    if (slot != null) _slot = slot;
    if (players != null) _players = players;
    if (checkedLocations != null) _updateCheckedLocations(checkedLocations);
    if (slotData != null) _slotData = slotData;
    if (slotInfo != null) _slotInfo = slotInfo;
    if (hintPoints != null) _hintPoints = hintPoints;
    if (tags != null) _tags = tags;
    if (password != null) _password = password;
    if (permissions != null) _permissions = permissions;
    if (hintCost != null) _hintCost = hintCost;
    if (locationCheckPoints != null) _locationCheckPoints = locationCheckPoints;
    if (games != null) _games = games;
    if (datapackageChecksums != null) {
      _datapackageChecksums = datapackageChecksums;
    }
    if (seedName != null) _seedName = seedName;
    if (time != null) _time = time;
  }
}
