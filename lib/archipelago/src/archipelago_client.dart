library;

import 'package:web_socket_channel/web_socket_channel.dart';

import 'server_to_client.dart';
import 'archipelago_client_settings.dart';
import 'archipelago_connector.dart';
import 'archipelago_session.dart';

final class ArchipelagoClient {
  final ArchipelagoSession _session;
  final Stream<ServerMessage> stream;

  ArchipelagoClient._(this._session, this.stream);

  static Future<ArchipelagoClient> connect({
    required String host,
    required int port,
    required String name,
    required String uuid,
    List<String> tags = const [],
    String? game,
    String? password,
    bool receiveOtherWorlds = false,
    bool receiveOwnWorld = false,
    bool receiveStartingInventory = false,
    bool receiveSlotData = false,
    DataPackageHandler? dataPackageHandler,
  }) async {
    final uri = Uri(host: host, port: port, scheme: 'ws');
    final clientSettings = ArchipelagoClientSettings(
      name: name,
      uuid: uuid,
      game: game,
      password: password,
      tags: tags,
      receiveOtherWorlds: receiveOtherWorlds,
      receiveOwnWorld: receiveOwnWorld,
      receiveStartingInventory: receiveStartingInventory,
      receiveSlotData: receiveSlotData,
    );

    final channel = WebSocketChannel.connect(uri);
    await channel.ready;
    final connector = ArchipelagoConnector(channel);
    final session = ArchipelagoSession(connector, clientSettings);
    await session.handshake(dataPackageHandler);
    final publicStream = _processStream(session, session.stream!);
    return ArchipelagoClient._(session, publicStream);
  }

  static Stream<ServerMessage> _processStream(
    ArchipelagoSession session,
    Stream<ServerMessage> stream,
  ) async* {
    await for (final event in stream) {
      if (event is RoomUpdate) {
        session.updateRoomInfo(event);
      }
      yield event;
    }
  }

  void changeTags(List<String> newTags) {
    _session.modifyClientSettings(tags: newTags);
  }

  void changeFlags(
    bool receiveOtherWorlds,
    bool receiveOwnWorld,
    bool receiveStartingInventory,
  ) {
    _session.modifyClientSettings(
      receiveOtherWorlds: receiveOtherWorlds,
      receiveOwnWorld: receiveOwnWorld,
      receiveStartingInventory: receiveStartingInventory,
    );
  }

  void sync() {
    _session.sync();
  }

  void scoutLocations(
    List<int> locations, [
    bool asHint = false,
    bool newHintsOnly = false,
  ]) {
    _session.scoutLocations(locations, asHint, newHintsOnly);
  }

  void hintUnspecified(int player, int location) {
    _session.updateHint(player, location, 0);
  }

  void hintUnneeded(int player, int location) {
    _session.updateHint(player, location, 1);
  }

  void hintAvoid(int player, int location) {
    _session.updateHint(player, location, 2);
  }

  void hintPriority(int player, int location) {
    _session.updateHint(player, location, 3);
  }

  void statusUnready() {
    _session.clientStatus(5);
  }

  void statusReady() {
    _session.clientStatus(10);
  }

  void statusPlaying() {
    _session.clientStatus(20);
  }

  void statusGoal() {
    _session.clientStatus(30);
  }

  void say(String message) {
    _session.say(message);
  }

  void getDataPackage(DataPackageHandler handler, [List<String>? games]) {
    _session.getDataPackage(handler, games);
  }

  void bounce({
    required Map<dynamic, dynamic> data,
    List<String>? games,
    List<int>? slots,
    List<String>? tags,
  }) {
    _session.bounce(data, games, slots, tags);
  }

  void getStorage(List<String> keys) {
    _session.getStorage(keys);
  }

  //TODO: Set storage operations

  void checkLocations(List<int> locations) {
    _session.checkLocations(locations);
  }
}
