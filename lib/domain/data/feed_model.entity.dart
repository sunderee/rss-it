import 'package:hive_ce/hive.dart';
import 'package:rss_it_library/models/gofeed_feed_model.dart';
import 'package:rss_it_library/models/parse_feed_model.dart';

final class FeedModelEntity extends HiveObject {
  final String url;
  final String title;
  final String description;
  final String? imageUrl;
  final String? imageTitle;
  final List<FeedItemEntity> items;

  FeedModelEntity({
    required this.url,
    required this.title,
    required this.description,
    this.imageUrl,
    this.imageTitle,
    required this.items,
  });

  factory FeedModelEntity.fromModel(ParseFeedResponseFeedModel model) {
    return FeedModelEntity(
      url: model.url,
      title: model.feed.title,
      description: model.feed.description,
      imageUrl: model.feed.image?.url,
      imageTitle: model.feed.image?.title,
      items:
          model.feed.items
              .map((item) => FeedItemEntity.fromModel(item))
              .toList(),
    );
  }

  ParseFeedResponseFeedModel toModel() {
    return ParseFeedResponseFeedModel(
      url: url,
      feed: GofeedFeedModel(
        title: title,
        description: description,
        image:
            imageUrl != null
                ? GofeedImageModel(url: imageUrl!, title: imageTitle ?? '')
                : null,
        items: items.map((item) => item.toModel()).toList(),
      ),
    );
  }
}

final class FeedItemEntity extends HiveObject {
  final String title;
  final String description;
  final String content;
  final String link;
  final String? imageUrl;
  final String? imageTitle;

  FeedItemEntity({
    required this.title,
    required this.description,
    required this.content,
    required this.link,
    this.imageUrl,
    this.imageTitle,
  });

  factory FeedItemEntity.fromModel(GofeedFeedItemModel model) {
    return FeedItemEntity(
      title: model.title,
      description: model.description,
      content: model.content,
      link: model.link,
      imageUrl: model.image?.url,
      imageTitle: model.image?.title,
    );
  }

  GofeedFeedItemModel toModel() {
    return GofeedFeedItemModel(
      title: title,
      description: description,
      content: content,
      link: link,
      image:
          imageUrl != null
              ? GofeedImageModel(url: imageUrl!, title: imageTitle ?? '')
              : null,
    );
  }
}
