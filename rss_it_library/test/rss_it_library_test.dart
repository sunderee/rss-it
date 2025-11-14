import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:rss_it_library/protos/feed.pb.dart';
import 'package:rss_it_library/rss_it_library.dart';

void main() {
  group('Protobuf Serialization', () {
    test('ValidateFeedRequest serialization and deserialization', () {
      const testUrl = 'https://example.com/rss.xml';
      final request = ValidateFeedRequest(url: testUrl);

      final buffer = request.writeToBuffer();
      expect(buffer.isNotEmpty, isTrue);

      final deserialized = ValidateFeedRequest.fromBuffer(buffer);
      expect(deserialized.url, equals(testUrl));
    });

    test('ValidateFeedResponse serialization and deserialization', () {
      final response = ValidateFeedResponse()..valid = true;

      final buffer = response.writeToBuffer();
      expect(buffer.isNotEmpty, isTrue);

      final deserialized = ValidateFeedResponse.fromBuffer(buffer);
      expect(deserialized.valid, isTrue);
    });

    test('ParseFeedsRequest serialization and deserialization', () {
      final request = ParseFeedsRequest()
        ..urls.addAll([
          'https://example.com/rss1.xml',
          'https://example.com/rss2.xml',
        ]);

      final buffer = request.writeToBuffer();
      expect(buffer.isNotEmpty, isTrue);

      final deserialized = ParseFeedsRequest.fromBuffer(buffer);
      expect(deserialized.urls.length, equals(2));
      expect(deserialized.urls[0], equals('https://example.com/rss1.xml'));
      expect(deserialized.urls[1], equals('https://example.com/rss2.xml'));
    });

    test('ParseFeedsResponse serialization and deserialization', () {
      final feed = Feed()
        ..url = 'https://example.com/rss.xml'
        ..title = 'Test Feed';

      final feedItem = FeedItem()
        ..title = 'Test Article'
        ..link = 'https://example.com/article/1';

      feed.items.add(feedItem);

      final response = ParseFeedsResponse()
        ..status = ParseFeedsStatus.SUCCESS
        ..feeds.add(feed)
        ..errors.add(
          ErrorDetail(message: 'warning', kind: ErrorKind.ERROR_KIND_PARSING),
        );

      final buffer = response.writeToBuffer();
      expect(buffer.isNotEmpty, isTrue);

      final deserialized = ParseFeedsResponse.fromBuffer(buffer);
      expect(deserialized.status, equals(ParseFeedsStatus.SUCCESS));
      expect(deserialized.feeds.length, equals(1));
      expect(deserialized.feeds[0].url, equals('https://example.com/rss.xml'));
      expect(deserialized.feeds[0].title, equals('Test Feed'));
      expect(deserialized.feeds[0].items.length, equals(1));
      expect(deserialized.feeds[0].items[0].title, equals('Test Article'));
      expect(deserialized.errors.length, equals(1));
      expect(deserialized.errors.first.message, equals('warning'));
    });
  });

  group('Buffer Length Prefix Handling', () {
    test('Length prefix encoding and decoding', () {
      final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
      final length = testData.length;

      // Encode: prepend 4-byte length (little endian)
      final encoded = Uint8List(4 + length);
      final byteData = ByteData.view(encoded.buffer);
      byteData.setUint32(0, length, Endian.little);
      encoded.setRange(4, 4 + length, testData);

      // Decode: read length prefix
      final lengthBytes = encoded.sublist(0, 4);
      final lengthByteData = ByteData.view(lengthBytes.buffer);
      final decodedLength = lengthByteData.getUint32(0, Endian.little);

      expect(decodedLength, equals(length));

      // Extract data
      final decodedData = encoded.sublist(4, 4 + decodedLength);
      expect(decodedData, equals(testData));
    });

    test('Length prefix with protobuf data', () {
      final request = ValidateFeedRequest(url: 'https://test.com/rss.xml');
      final protobufData = request.writeToBuffer();

      // Encode with length prefix
      final encoded = Uint8List(4 + protobufData.length);
      final byteData = ByteData.view(encoded.buffer);
      byteData.setUint32(0, protobufData.length, Endian.little);
      encoded.setRange(4, 4 + protobufData.length, protobufData);

      // Decode
      final lengthBytes = encoded.sublist(0, 4);
      final lengthByteData = ByteData.view(lengthBytes.buffer);
      final dataLength = lengthByteData.getUint32(0, Endian.little);

      final extractedData = encoded.sublist(4, 4 + dataLength);
      final deserialized = ValidateFeedRequest.fromBuffer(extractedData);

      expect(deserialized.url, equals('https://test.com/rss.xml'));
    });
  });

  group('Feed Protobuf Messages', () {
    test('Feed with all fields', () {
      final feed = Feed()
        ..url = 'https://example.com/rss.xml'
        ..title = 'Test Feed'
        ..description = 'Test Description'
        ..image = 'https://example.com/image.png';

      final item1 = FeedItem()
        ..title = 'Article 1'
        ..link = 'https://example.com/article1'
        ..description = 'Description 1'
        ..published = '2024-01-01T12:00:00Z';

      final item2 = FeedItem()
        ..title = 'Article 2'
        ..link = 'https://example.com/article2';

      feed.items.addAll([item1, item2]);

      expect(feed.url, equals('https://example.com/rss.xml'));
      expect(feed.title, equals('Test Feed'));
      expect(feed.description, equals('Test Description'));
      expect(feed.image, equals('https://example.com/image.png'));
      expect(feed.items.length, equals(2));
      expect(feed.items[0].title, equals('Article 1'));
      expect(feed.items[1].title, equals('Article 2'));
    });

    test('Feed with optional fields missing', () {
      final feed = Feed()
        ..url = 'https://example.com/rss.xml'
        ..title = 'Test Feed';

      expect(feed.hasDescription(), isFalse);
      expect(feed.hasImage(), isFalse);
      expect(feed.items.isEmpty, isTrue);
    });

    test('FeedItem with optional fields', () {
      final item = FeedItem()..title = 'Test Article';

      expect(item.title, equals('Test Article'));
      expect(item.hasLink(), isFalse);
      expect(item.hasDescription(), isFalse);
      expect(item.hasImage(), isFalse);
      expect(item.hasPublished(), isFalse);
    });
  });

  group('ParseFeedsStatus Enum', () {
    test('SUCCESS status', () {
      expect(ParseFeedsStatus.SUCCESS.value, equals(0));
      expect(ParseFeedsStatus.SUCCESS.name, equals('SUCCESS'));
    });

    test('ERROR status', () {
      expect(ParseFeedsStatus.ERROR.value, equals(1));
      expect(ParseFeedsStatus.ERROR.name, equals('ERROR'));
    });

    test('PARTIAL status', () {
      expect(ParseFeedsStatus.PARTIAL.value, equals(2));
      expect(ParseFeedsStatus.PARTIAL.name, equals('PARTIAL'));
    });

    test('Status values', () {
      expect(ParseFeedsStatus.values.length, equals(3));
      expect(
        ParseFeedsStatus.values,
        containsAll([
          ParseFeedsStatus.SUCCESS,
          ParseFeedsStatus.ERROR,
          ParseFeedsStatus.PARTIAL,
        ]),
      );
    });
  });

  group('Error Handling', () {
    test('Empty buffer creates empty request', () {
      // Protobuf doesn't throw on empty buffer, it creates an empty object
      final request = ValidateFeedRequest.fromBuffer([]);
      expect(request.url, isEmpty);
    });

    test('Invalid buffer may throw or create empty object', () {
      final invalidBuffer = Uint8List.fromList([255, 255, 255, 255]);
      // Protobuf may or may not throw on invalid data depending on version
      try {
        final request = ValidateFeedRequest.fromBuffer(invalidBuffer);
        // If it doesn't throw, it creates an object (possibly empty)
        expect(request, isNotNull);
      } catch (e) {
        // If it throws, that's also acceptable
        expect(e, isA<Exception>());
      }
    });
  });

  group('Edge Cases', () {
    test('Empty URL in ValidateFeedRequest', () {
      final request = ValidateFeedRequest(url: '');
      final buffer = request.writeToBuffer();
      final deserialized = ValidateFeedRequest.fromBuffer(buffer);
      expect(deserialized.url, isEmpty);
    });

    test('Empty URLs list in ParseFeedsRequest', () {
      final request = ParseFeedsRequest();
      final buffer = request.writeToBuffer();
      final deserialized = ParseFeedsRequest.fromBuffer(buffer);
      expect(deserialized.urls.isEmpty, isTrue);
    });

    test('ParseFeedsResponse with errors', () {
      final response = ParseFeedsResponse()
        ..status = ParseFeedsStatus.ERROR
        ..errors.addAll([
          ErrorDetail(message: 'Error 1', kind: ErrorKind.ERROR_KIND_NETWORK),
          ErrorDetail(message: 'Error 2', kind: ErrorKind.ERROR_KIND_PARSING),
        ]);

      final buffer = response.writeToBuffer();
      final deserialized = ParseFeedsResponse.fromBuffer(buffer);

      expect(deserialized.status, equals(ParseFeedsStatus.ERROR));
      expect(deserialized.errors.length, equals(2));
      expect(deserialized.errors[0].message, equals('Error 1'));
      expect(deserialized.errors[1].kind, equals(ErrorKind.ERROR_KIND_PARSING));
    });

    test('ParseFeedsResponse PARTIAL status', () {
      final feed1 = Feed()
        ..url = 'https://example.com/rss1.xml'
        ..title = 'Feed 1';

      final response = ParseFeedsResponse()
        ..status = ParseFeedsStatus.PARTIAL
        ..feeds.add(feed1)
        ..errors.add(
          ErrorDetail(
            message: 'Failed to parse rss2.xml',
            kind: ErrorKind.ERROR_KIND_PARSING,
            url: 'https://example.com/rss2.xml',
          ),
        );

      expect(response.status, equals(ParseFeedsStatus.PARTIAL));
      expect(response.feeds.length, equals(1));
      expect(response.errors.length, equals(1));
      expect(response.errors.first.url, equals('https://example.com/rss2.xml'));
    });
  });

  group('RssItLibraryException', () {
    test('toString includes context information', () {
      final detail = ErrorDetail(
        message: 'boom',
        kind: ErrorKind.ERROR_KIND_VALIDATION,
        url: 'https://example.invalid',
      );
      final error = RssItLibraryException('validate', detail);

      final rendered = error.toString();
      expect(rendered, contains('validate'));
      expect(rendered, contains('boom'));
      expect(rendered, contains('example.invalid'));
    });

    test('internal constructor defaults to internal error kind', () {
      final error = RssItLibraryException.internal('parse', 'fatal');
      expect(error.detail.kind, equals(ErrorKind.ERROR_KIND_INTERNAL));
      expect(error.detail.message, equals('fatal'));
    });
  });
}
