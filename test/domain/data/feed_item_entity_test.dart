import 'package:rss_it/domain/data/feed_item_entity.dart';
import 'package:rss_it_library/protos/feed.pb.dart';
import 'package:test/test.dart';

void main() {
  group('FeedItemEntity', () {
    test('fromJson creates FeedItemEntity with all fields', () {
      final json = {
        'id': 1,
        'feed_id': 10,
        'link': 'https://example.com/article/1',
        'title': 'Test Article',
        'description': 'Test Description',
        'image_url': 'https://example.com/image.png',
        'published_at': '2024-01-01T12:00:00.000Z',
        'created_at': '2024-01-01T13:00:00.000Z',
      };

      final entity = FeedItemEntity.fromJson(json);

      expect(entity.id, equals(1));
      expect(entity.feedID, equals(10));
      expect(entity.link, equals('https://example.com/article/1'));
      expect(entity.title, equals('Test Article'));
      expect(entity.description, equals('Test Description'));
      expect(entity.imageURL, equals('https://example.com/image.png'));
      expect(
        entity.publishedAt,
        equals(DateTime.parse('2024-01-01T12:00:00.000Z')),
      );
      expect(
        entity.createdAt,
        equals(DateTime.parse('2024-01-01T13:00:00.000Z')),
      );
    });

    test('fromJson creates FeedItemEntity with nullable fields as null', () {
      final json = {
        'id': 1,
        'feed_id': 10,
        'link': 'https://example.com/article/1',
        'title': 'Test Article',
        'created_at': '2024-01-01T13:00:00.000Z',
      };

      final entity = FeedItemEntity.fromJson(json);

      expect(entity.id, equals(1));
      expect(entity.feedID, equals(10));
      expect(entity.link, equals('https://example.com/article/1'));
      expect(entity.title, equals('Test Article'));
      expect(entity.description, isNull);
      expect(entity.imageURL, isNull);
      expect(entity.publishedAt, isNull);
    });

    test('toJson converts FeedItemEntity to JSON with all fields', () {
      final entity = FeedItemEntity(
        id: 1,
        feedID: 10,
        link: 'https://example.com/article/1',
        title: 'Test Article',
        description: 'Test Description',
        imageURL: 'https://example.com/image.png',
        publishedAt: DateTime.parse('2024-01-01T12:00:00.000Z'),
        createdAt: DateTime.parse('2024-01-01T13:00:00.000Z'),
      );

      final json = entity.toJson();

      expect(json['id'], equals(1));
      expect(json['feed_id'], equals(10));
      expect(json['link'], equals('https://example.com/article/1'));
      expect(json['title'], equals('Test Article'));
      expect(json['description'], equals('Test Description'));
      expect(json['image_url'], equals('https://example.com/image.png'));
      expect(json['published_at'], equals('2024-01-01T12:00:00.000Z'));
      expect(json['created_at'], equals('2024-01-01T13:00:00.000Z'));
    });

    test('toJson excludes id when null', () {
      final entity = FeedItemEntity(
        feedID: 10,
        link: 'https://example.com/article/1',
        title: 'Test Article',
        description: null,
        imageURL: null,
        publishedAt: null,
        createdAt: DateTime.parse('2024-01-01T13:00:00.000Z'),
      );

      final json = entity.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['feed_id'], equals(10));
    });

    test('toJson includes nullable fields when null', () {
      final entity = FeedItemEntity(
        feedID: 10,
        link: 'https://example.com/article/1',
        title: 'Test Article',
        description: null,
        imageURL: null,
        publishedAt: null,
        createdAt: DateTime.parse('2024-01-01T13:00:00.000Z'),
      );

      final json = entity.toJson();

      expect(json['description'], isNull);
      expect(json['image_url'], isNull);
      expect(json['published_at'], isNull);
    });

    test('toJson excludes published_at when null', () {
      final entity = FeedItemEntity(
        feedID: 10,
        link: 'https://example.com/article/1',
        title: 'Test Article',
        description: null,
        imageURL: null,
        publishedAt: null,
        createdAt: DateTime.parse('2024-01-01T13:00:00.000Z'),
      );

      final json = entity.toJson();

      expect(json['published_at'], isNull);
    });

    test(
      'fromRemoteFeedItem creates FeedItemEntity from protobuf FeedItem',
      () {
        final feedItem = FeedItem()
          ..title = 'Test Article'
          ..link = 'https://example.com/article/1'
          ..description = 'Test Description'
          ..image = 'https://example.com/image.png'
          ..published = '2024-01-01T12:00:00Z';

        final entity = FeedItemEntity.fromRemoteFeedItem(10, feedItem);

        expect(entity.id, isNull);
        expect(entity.feedID, equals(10));
        expect(entity.link, equals('https://example.com/article/1'));
        expect(entity.title, equals('Test Article'));
        expect(entity.description, equals('Test Description'));
        expect(entity.imageURL, equals('https://example.com/image.png'));
        expect(
          entity.publishedAt,
          equals(DateTime.parse('2024-01-01T12:00:00Z')),
        );
        expect(entity.createdAt, isA<DateTime>());
      },
    );

    test('fromRemoteFeedItem handles missing optional fields', () {
      final feedItem = FeedItem()..title = 'Test Article';

      final entity = FeedItemEntity.fromRemoteFeedItem(10, feedItem);

      expect(entity.feedID, equals(10));
      expect(entity.title, equals('Test Article'));
      expect(entity.link, isEmpty);
      expect(entity.description, isEmpty);
      expect(entity.imageURL, isEmpty);
      expect(entity.publishedAt, isNull);
    });

    test('fromRemoteFeedItem handles invalid published date', () {
      final feedItem = FeedItem()
        ..title = 'Test Article'
        ..published = 'invalid-date';

      final entity = FeedItemEntity.fromRemoteFeedItem(10, feedItem);

      expect(entity.publishedAt, isNull);
    });

    test('fromRemoteFeedItem sets createdAt to current time', () {
      final feedItem = FeedItem()..title = 'Test Article';

      final beforeCreation = DateTime.now();
      final entity = FeedItemEntity.fromRemoteFeedItem(10, feedItem);
      final afterCreation = DateTime.now();

      expect(
        entity.createdAt.isAfter(
          beforeCreation.subtract(const Duration(seconds: 1)),
        ),
        isTrue,
      );
      expect(
        entity.createdAt.isBefore(
          afterCreation.add(const Duration(seconds: 1)),
        ),
        isTrue,
      );
    });

    test('round-trip: fromJson then toJson', () {
      final originalJson = {
        'id': 1,
        'feed_id': 10,
        'link': 'https://example.com/article/1',
        'title': 'Test Article',
        'description': 'Test Description',
        'image_url': 'https://example.com/image.png',
        'published_at': '2024-01-01T12:00:00.000Z',
        'created_at': '2024-01-01T13:00:00.000Z',
      };

      final entity = FeedItemEntity.fromJson(originalJson);
      final roundTripJson = entity.toJson();

      expect(roundTripJson['id'], equals(originalJson['id']));
      expect(roundTripJson['feed_id'], equals(originalJson['feed_id']));
      expect(roundTripJson['link'], equals(originalJson['link']));
      expect(roundTripJson['title'], equals(originalJson['title']));
      expect(roundTripJson['description'], equals(originalJson['description']));
      expect(roundTripJson['image_url'], equals(originalJson['image_url']));
      expect(
        roundTripJson['published_at'],
        equals(originalJson['published_at']),
      );
      expect(roundTripJson['created_at'], equals(originalJson['created_at']));
    });
  });
}
