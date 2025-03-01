library;

import 'dart:async';
import 'dart:convert';

import 'client_to_server.dart';
import 'server_to_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A connection to an Archipelago server.
/// Can send and receive lists of JSON objects.
interface class ArchipelagoConnector {
  final WebSocketChannel _channel;
  Future<void> get ready => _channel.ready;
  final StreamSink _sink;
  final Stream<ServerMessage> stream;

  ArchipelagoConnector._(this._channel, this._sink, this.stream);

  factory ArchipelagoConnector(String host, int port) {
    final channel = WebSocketChannel.connect(
      Uri(host: host, port: port, scheme: 'ws'),
    );
    final stream = channel.stream
        .map((event) => jsonDecode(event) as List<dynamic>)
        .expand((x) => x)
        .map((x) => ServerMessage.fromJson(x));
    final StreamSink sink = channel.sink;
    return ArchipelagoConnector._(channel, sink, stream);
  }

  void send(ClientMessage message) {
    sendMultiple([message]);
  }

  void sendMultiple(List<ClientMessage> messages) {
    _sink.add(jsonEncode(messages));
  }
}
