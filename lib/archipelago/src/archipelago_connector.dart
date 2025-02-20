library;

import 'dart:async';
import 'dart:convert';

import 'package:stream_channel/stream_channel.dart';

/// A connection to an Archipelago server.
/// Can send and receive lists of JSON objects.
interface class ArchipelagoConnector {
  final StreamChannel _channel;
  final StreamSink _sink;
  final Stream<Map<String, dynamic>> stream;

  ArchipelagoConnector._(this._channel, this._sink, this.stream);

  factory ArchipelagoConnector(StreamChannel channel) {
    final stream =
        channel.stream
            .map((event) => jsonDecode(event) as List<Map<String, dynamic>>)
            .expand((x) => x)
            .asBroadcastStream();
    final StreamSink sink = channel.sink;
    return ArchipelagoConnector._(channel, sink, stream);
  }

  void send(Map<String, dynamic> message) {
    sendMultiple([message]);
  }

  void sendMultiple(List<Map<String, dynamic>> messages) {
    _sink.add(jsonEncode(messages));
  }
}
