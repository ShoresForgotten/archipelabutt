library;

import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'client_to_server.dart';
import 'protocol_types.dart';
import 'server_to_client.dart';

abstract class _ArchipelagoGlobal {
  static Uuid? _uuidGenerator;

  static String generateUUID() {
    _ArchipelagoGlobal._uuidGenerator ??= Uuid();
    return _uuidGenerator!.v4();
  }

  static NetworkVersion get supportedVersion {
    return NetworkVersion(0, 5, 1);
  }
}

class ConnectionInfo {
  final String _address;
  final int _port;
  final String _userName;
  final String _password;
  final String? _game;
  final List<String> _tags;
  final ItemsHandlingFlags _itemFlags;
  final bool _receiveSlotData;
  final bool _getDataPackage;

  ConnectionInfo._(
    this._address,
    this._port,
    this._userName,
    this._password,
    this._game,
    this._tags,
    this._itemFlags,
    this._receiveSlotData,
    this._getDataPackage,
  );

  factory ConnectionInfo({
    required String address,
    required int port,
    required String userName,
    String password = '',
    String? game,
    List<String>? tags,
    bool receiveOtherWorlds = false,
    bool receiveOwnWorld = false,
    bool receiveStartingInventory = false,
    bool receiveSlotData = false,
    bool getDataPackage = false,
  }) {
    if (game == null &&
        (tags == null ||
            !tags.contains('HintGame') ||
            !tags.contains('Tracker') ||
            !tags.contains('TextOnly'))) {
      throw 'Tags must contain HintGame, Tracker, or TextOnly if game is null';
    }
    if ((receiveOwnWorld || receiveStartingInventory) && receiveOtherWorlds) {
      throw 'Receiving from other worlds must be enabled to receive items from own world';
    }
    return ConnectionInfo._(
      address,
      port,
      userName,
      password,
      game,
      tags ?? [],
      ItemsHandlingFlags(
        receiveOtherWorlds,
        receiveOwnWorld,
        receiveStartingInventory,
      ),
      receiveSlotData,
      getDataPackage,
    );
  }
}

class ArchipelagoConnection {
  final WebSocketChannel _channel;
  final Stream<ServerMessage> _messages;
  final WebSocketSink _sink;
  final String _clientUUID;
  final ConnectionInfo _connectionInfo;
  final RoomInfo _roomInfo;

  Stream<ServerMessage> get stream => _messages;
  Permission get releasePermission => _roomInfo.release;
  Permission get collectPermission => _roomInfo.collect;
  Permission get remainingPermission => _roomInfo.remaining;
  List<String> get roomTags => _roomInfo.tags;
  int get hintCost => _roomInfo.hintCost;

  ArchipelagoConnection._(
    this._channel,
    this._messages,
    this._sink,
    this._clientUUID,
    this._connectionInfo,
    this._roomInfo,
  );

  static Future<ArchipelagoConnection> connect(
    ConnectionInfo connectionInfo,
  ) async {
    final uuid = _ArchipelagoGlobal.generateUUID();
    final uri = Uri(
      host: connectionInfo._address,
      port: connectionInfo._port,
      scheme: 'ws',
    );
    final channel = WebSocketChannel.connect(uri);
    final stream =
        channel.stream
            .map((event) => ServerMessage.fromJson(event))
            .asBroadcastStream();
    await channel.ready;
    final WebSocketSink sink = channel.sink;
    int handshakeLength;
    RoomInfo roomInfo;
    (handshakeLength, roomInfo) = await _handshake(
      stream,
      sink,
      connectionInfo,
    );
    return ArchipelagoConnection._(
      channel,
      stream.skip(handshakeLength),
      sink,
      uuid,
      connectionInfo,
      roomInfo,
    );
  }

  static Future<(int handshakeLength, RoomInfo roomInfo)> _handshake(
    Stream<ServerMessage> stream,
    WebSocketSink sink,
    ConnectionInfo connectionInfo,
  ) async {
    int messageSkip = 0;

    final ServerMessage roomInfo = await stream.first;
    if (roomInfo is RoomInfo) {
      // Do something with that
    } else {
      throw 'Did not recieve RoomInfo as first packet from server.';
    }

    if (connectionInfo._getDataPackage) {
      sink.add(GetDataPackage(null));

      final ServerMessage dataPackage = await stream.skip(++messageSkip).first;

      if (dataPackage is DataPackage) {
        // Do something with this
      } else {
        throw 'Did not recieve DataPackage as response to GetDataPackage.';
      }
    }

    sink.add(
      Connect(
        roomInfo.password ? connectionInfo._password : null,
        connectionInfo._game,
        connectionInfo._userName,
        _ArchipelagoGlobal.generateUUID(),
        _ArchipelagoGlobal.supportedVersion,
        connectionInfo._itemFlags,
        connectionInfo._tags,
        connectionInfo._receiveSlotData,
      ),
    );

    final ServerMessage connectionStatus =
        await stream.skip(++messageSkip).first;

    if (connectionStatus is Connected) {
      // Connected
    } else if (connectionStatus is ConnectionRefused) {
      // Connection Failed
    } else {
      // other error
    }

    return (++messageSkip, roomInfo);
  }

  void send(ClientMessage message) {
    _sink.add(message.toJson());
  }
}
