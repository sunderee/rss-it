import 'package:rss_it_library/models/gofeed_feed_model.dart';

final class ParseFeedRequestModel {
  final List<String> urls;

  ParseFeedRequestModel({required this.urls});

  Map<String, dynamic> toJson() => {'urls': urls};
}

final class ParseFeedResponseFeedModel {
  final String url;
  final GofeedFeedModel feed;

  ParseFeedResponseFeedModel({required this.url, required this.feed});

  factory ParseFeedResponseFeedModel.fromJson(Map<String, dynamic> json) {
    return ParseFeedResponseFeedModel(
      url: json['url'] as String,
      feed: GofeedFeedModel.fromJson(json['feed'] as Map<String, dynamic>),
    );
  }
}

final class ParseFeedResponseModel {
  final String status;
  final List<String> errors;
  final List<ParseFeedResponseFeedModel> feeds;

  ParseFeedResponseModel({
    required this.status,
    required this.errors,
    required this.feeds,
  });

  factory ParseFeedResponseModel.fromJson(Map<String, dynamic> json) {
    return ParseFeedResponseModel(
      status: json['status'] as String,
      errors: (json['errors'] as List<dynamic>).cast<String>(),
      feeds:
          (json['feeds'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>()
              .map((item) => ParseFeedResponseFeedModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}
