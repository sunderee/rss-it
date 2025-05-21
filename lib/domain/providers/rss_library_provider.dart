import 'package:rss_it_library/models/parse_feed_model.dart';

abstract interface class RssLibraryProvider {
  Future<bool> validateFeedURL(String url);
  Future<ParseFeedResponseModel> parseFeedURLs(List<String> urls);
}
