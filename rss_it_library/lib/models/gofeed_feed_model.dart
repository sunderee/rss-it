final class GofeedImageModel {
  final String url;
  final String title;

  GofeedImageModel({required this.url, required this.title});

  factory GofeedImageModel.fromJson(Map<String, dynamic> json) {
    return GofeedImageModel(
      url: json.containsKey('url') ? json['url'] as String? ?? '' : '',
      title: json.containsKey('title') ? json['title'] as String? ?? '' : '',
    );
  }
}

final class GofeedFeedItemModel {
  final String title;
  final String description;
  final String content;
  final String link;
  final GofeedImageModel? image;

  GofeedFeedItemModel({
    required this.title,
    required this.description,
    required this.content,
    required this.link,
    required this.image,
  });

  factory GofeedFeedItemModel.fromJson(Map<String, dynamic> json) {
    return GofeedFeedItemModel(
      title: json.containsKey('title') ? json['title'] as String? ?? '' : '',
      description:
          json.containsKey('description')
              ? json['description'] as String? ?? ''
              : '',
      content:
          json.containsKey('content') ? json['content'] as String? ?? '' : '',
      link: json.containsKey('link') ? json['link'] as String? ?? '' : '',
      image:
          json.containsKey('image')
              ? GofeedImageModel.fromJson(json['image'] as Map<String, dynamic>)
              : null,
    );
  }
}

final class GofeedFeedModel {
  final String title;
  final String description;
  final GofeedImageModel? image;
  final List<GofeedFeedItemModel> items;

  GofeedFeedModel({
    required this.title,
    required this.description,
    required this.image,
    required this.items,
  });

  factory GofeedFeedModel.fromJson(Map<String, dynamic> json) {
    return GofeedFeedModel(
      title: json.containsKey('title') ? json['title'] as String? ?? '' : '',
      description:
          json.containsKey('description')
              ? json['description'] as String? ?? ''
              : '',
      image:
          json.containsKey('image')
              ? GofeedImageModel.fromJson(json['image'] as Map<String, dynamic>)
              : null,
      items:
          json.containsKey('items')
              ? (json['items'] as List<dynamic>)
                  .cast<Map<String, dynamic>>()
                  .map((item) => GofeedFeedItemModel.fromJson(item))
                  .toList()
              : [],
    );
  }
}
