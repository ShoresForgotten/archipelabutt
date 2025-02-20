import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:stream_channel/stream_channel.dart';

import 'package:archipelabutt/archipelago/archipelago.dart';
import 'package:archipelabutt/archipelago/src/client_to_server.dart' as client;
import 'package:archipelabutt/archipelago/src/server_to_client.dart' as server;
import 'package:archipelabutt/archipelago/src/protocol_types.dart';
import 'package:uuid/uuid.dart';

@GenerateNiceMocks([
  MockSpec<StreamChannel>(),
  MockSpec<StreamSink>(),
  MockSpec<ArchipelagoConnector>(),
])
import 'archipelago_test.mocks.dart';

typedef JSON = Map<String, dynamic>;

void main() {
  group('Client API', () {
    test('Connect without GetDataPackage', () async {
      final MockArchipelagoConnector mockConnector = MockArchipelagoConnector();
      final NetworkVersion networkVersion = NetworkVersion(0, 5, 1);

      when(mockConnector.stream).thenAnswer(
        (_) => Stream.fromIterable([
          server.RoomInfo(
            networkVersion,
            networkVersion,
            [],
            false,
            Permission.auto,
            Permission.auto,
            Permission.auto,
            5,
            1,
            [],
            {},
            'potato',
            DateTime.now(),
          ),
          server.Connected(
            0,
            1,
            [NetworkPlayer(0, 1, 'Bob Hamelin', 'Bob')],
            [],
            [],
            {1: NetworkSlot('Bob', 'Spacewar', SlotType(true, false), [])},
            0,
          ),
        ]),
      );
      final uuid = Uuid().v4();

      final clientSettings = ArchipelagoClientSettings(
        game: 'Spacewar',
        tags: [],
        receiveOtherWorlds: true,
        receiveOwnWorld: false,
        receiveStartingInventory: false,
        receiveSlotData: false,
      );

      final archipelagoClient = await ArchipelagoClient.connectUsingConnector(
        mockConnector,
        clientSettings,
        'Bob',
        uuid,
      );

      expect(
        verify(mockConnector.send(captureAny)).captured.single,
        client.ConnectMessage(
          null,
          'Spacewar',
          'Bob',
          uuid,
          networkVersion,
          true,
          false,
          false,
          [],
          false,
        ),
      );
    });
  });
  group('Miscellaneous types', () {
    group('Item flags', () {
      test('Serialization', () {
        for (var i = 0; i < 8; i++) {
          var obj = NetworkItemFlags(
            logicalAdvancement: i % 2 == 1,
            useful: i % 4 >= 2,
            trap: i > 3,
          );
          expect(obj.toJson(), i);
        }
      });
      test('Deserialization', () {
        for (var i = 0; i < 8; i++) {
          var json = NetworkItemFlags.fromJson(i);
          expect(
            json.logicalAdvancement,
            i % 2 == 1,
            reason: 'Logical advancement',
          );
          expect(json.useful, i % 4 >= 2, reason: 'Useful');
          expect(json.trap, i > 3, reason: 'Trap');
        }
      });
    });
    group('JSON message part deserialization', () {
      test('Text', () {
        final JSON json = {'type': 'text', 'text': 'Lorem ipsum'};
        expect(JSONMessagePart.fromJson(json).runtimeType, TextMessagePart);
      });
      test('Player ID', () {
        final JSON json = {'type': 'player_id', 'text': '1'};
        expect(JSONMessagePart.fromJson(json).runtimeType, PlayerIDMessagePart);
      });
      test('Player name', () {
        final JSON json = {'type': 'player_name', 'text': 'Bob'};
        expect(
          JSONMessagePart.fromJson(json).runtimeType,
          PlayerNameMessagePart,
        );
      });
      test('Item ID', () {
        final JSON json = {
          'type': 'item_id',
          'text': '1',
          'flags': 7,
          'player': 1,
        };
        expect(JSONMessagePart.fromJson(json).runtimeType, ItemIDMessagePart);
      });
      test('Item name', () {
        final JSON json = {
          'type': 'item_name',
          'text': 'Sword',
          'flags': 7,
          'player': 1,
        };
        expect(JSONMessagePart.fromJson(json).runtimeType, ItemNameMessagePart);
      });
      test('Location ID', () {
        final JSON json = {'type': 'location_id', 'text': '1', 'player': 1};
        expect(
          JSONMessagePart.fromJson(json).runtimeType,
          LocationIDMessagePart,
        );
      });
      test('Location name', () {
        final JSON json = {
          'type': 'location_name',
          'text': 'Bielefeld',
          'player': 1,
        };
        expect(
          JSONMessagePart.fromJson(json).runtimeType,
          LocationNameMessagePart,
        );
      });
      test('Entrance name', () {
        final JSON json = {
          'type': 'entrance_name',
          'text': 'Bielefeld city limit',
        };
        expect(
          JSONMessagePart.fromJson(json).runtimeType,
          EntranceNameMessagePart,
        );
      });
      test('Hint status', () {
        final JSON json = {
          'type': 'hint_status',
          'text': 'Sword',
          'status': 30,
        };
        expect(
          JSONMessagePart.fromJson(json).runtimeType,
          HintStatusMessagePart,
        );
      });
      test('Color', () {
        final JSON json = {
          'type': 'color',
          'text': 'Lorem ipsum',
          'color': 'magenta',
        };
        expect(JSONMessagePart.fromJson(json).runtimeType, ColorMessagePart);
      });
    });
    test('Slot type deserialization', () {
      for (var i = 0; i < 4; i++) {
        final obj = SlotType.fromJson(i);
        expect(obj.player, i % 2 == 1);
        expect(obj.group, i > 1);
      }
    });
  });

  //TODO: Write more tests
}
