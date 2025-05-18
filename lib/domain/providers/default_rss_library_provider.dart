import 'package:rss_it/domain/providers/rss_library_provider.dart';
import 'package:rss_it_library/models/parse_feed_model.dart';
import 'package:rss_it_library/rss_it_library.dart' as rss_it_library;

final class DefaultRSSLibraryProvider implements RssLibraryProvider {
  @override
  Future<ParseFeedResponseModel> parseFeedURLs(List<String> urls) =>
      rss_it_library.parseFeedURLs(urls);

  @override
  Future<bool> validateFeedURL(String url) =>
      rss_it_library.validateFeedURL(url);
}
