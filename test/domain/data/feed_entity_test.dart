import 'package:rss_it/domain/data/feed_entity.dart';
import 'package:rss_it_library/protos/feed.pb.dart';
import 'package:test/test.dart';

void main() {
  group('FeedEntity', () {
    test('fromJson creates FeedEntity with all fields', () {
      final json = {
        'id': 1,
        'url': 'https://example.com/rss.xml',
        'title': 'Test Feed',
        'description': 'Test Description',
        'thumbnail_url': 'https://example.com/thumbnail.png',
        'added_at': '2024-01-01T12:00:00.000Z',
      };

      final entity = FeedEntity.fromJson(json);

      expect(entity.id, equals(1));
      expect(entity.url, equals('https://example.com/rss.xml'));
      expect(entity.title, equals('Test Feed'));
      expect(entity.description, equals('Test Description'));
      expect(entity.thumbnailURL, equals('https://example.com/thumbnail.png'));
      expect(entity.addedAt, equals(DateTime.parse('2024-01-01T12:00:00.000Z')));
    });

    test('fromJson creates FeedEntity with nullable fields as null', () {
      final json = {
        'id': 1,
        'url': 'https://example.com/rss.xml',
        'title': 'Test Feed',
        'added_at': '2024-01-01T12:00:00.000Z',
      };

      final entity = FeedEntity.fromJson(json);

      expect(entity.id, equals(1));
      expect(entity.url, equals('https://example.com/rss.xml'));
      expect(entity.title, equals('Test Feed'));
      expect(entity.description, isNull);
      expect(entity.thumbnailURL, isNull);
    });

    test('toJson converts FeedEntity to JSON with all fields', () {
      final entity = FeedEntity(
        id: 1,
        url: 'https://example.com/rss.xml',
        title: 'Test Feed',
        description: 'Test Description',
        thumbnailURL: 'https://example.com/thumbnail.png',
        addedAt: DateTime.parse('2024-01-01T12:00:00.000Z'),
      );

      final json = entity.toJson();

      expect(json['id'], equals(1));
      expect(json['url'], equals('https://example.com/rss.xml'));
      expect(json['title'], equals('Test Feed'));
      expect(json['description'], equals('Test Description'));
      expect(json['thumbnail_url'], equals('https://example.com/thumbnail.png'));
      expect(json['added_at'], equals('2024-01-01T12:00:00.000Z'));
    });

    test('toJson excludes id when null', () {
      final entity = FeedEntity(
        url: 'https://example.com/rss.xml',
        title: 'Test Feed',
        description: null,
        thumbnailURL: null,
        addedAt: DateTime.parse('2024-01-01T12:00:00.000Z'),
      );

      final json = entity.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['url'], equals('https://example.com/rss.xml'));
    });

    test('toJson includes nullable fields when null', () {
      final entity = FeedEntity(
        url: 'https://example.com/rss.xml',
        title: 'Test Feed',
        description: null,
        thumbnailURL: null,
        addedAt: DateTime.parse('2024-01-01T12:00:00.000Z'),
      );

      final json = entity.toJson();

      expect(json['description'], isNull);
      expect(json['thumbnail_url'], isNull);
    });

    test('fromRemoteFeed creates FeedEntity from protobuf Feed', () {
      final feed = Feed()
        ..url = 'https://example.com/rss.xml'
        ..title = 'Test Feed'
        ..description = 'Test Description'
        ..image = 'https://example.com/thumbnail.png';

      final entity = FeedEntity.fromRemoteFeed(feed);

      expect(entity.id, isNull);
      expect(entity.url, equals('https://example.com/rss.xml'));
      expect(entity.title, equals('Test Feed'));
      expect(entity.description, equals('Test Description'));
      expect(entity.thumbnailURL, equals('https://example.com/thumbnail.png'));
      expect(entity.addedAt, isA<DateTime>());
    });

    test('fromRemoteFeed handles missing optional fields', () {
      final feed = Feed()
        ..url = 'https://example.com/rss.xml'
        ..title = 'Test Feed';

      final entity = FeedEntity.fromRemoteFeed(feed);

      expect(entity.url, equals('https://example.com/rss.xml'));
      expect(entity.title, equals('Test Feed'));
      expect(entity.description, isEmpty);
      expect(entity.thumbnailURL, isEmpty);
    });

    test('fromRemoteFeed sets addedAt to current time', () {
      final feed = Feed()
        ..url = 'https://example.com/rss.xml'
        ..title = 'Test Feed';

      final beforeCreation = DateTime.now();
      final entity = FeedEntity.fromRemoteFeed(feed);
      final afterCreation = DateTime.now();

      expect(
        entity.addedAt.isAfter(beforeCreation.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        entity.addedAt.isBefore(afterCreation.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('round-trip: fromJson then toJson', () {
      final originalJson = {
        'id': 1,
        'url': 'https://example.com/rss.xml',
        'title': 'Test Feed',
        'description': 'Test Description',
        'thumbnail_url': 'https://example.com/thumbnail.png',
        'added_at': '2024-01-01T12:00:00.000Z',
      };

      final entity = FeedEntity.fromJson(originalJson);
      final roundTripJson = entity.toJson();

      expect(roundTripJson['id'], equals(originalJson['id']));
      expect(roundTripJson['url'], equals(originalJson['url']));
      expect(roundTripJson['title'], equals(originalJson['title']));
      expect(roundTripJson['description'], equals(originalJson['description']));
      expect(roundTripJson['thumbnail_url'], equals(originalJson['thumbnail_url']));
      expect(roundTripJson['added_at'], equals(originalJson['added_at']));
    });
  });
}

