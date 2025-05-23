import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:rss_it_library/protos/feed.pb.dart';

import 'rss_it_library_bindings_generated.dart';

// Custom models for RSS feeds
class FeedItem {
  final String title;
  final String? description;
  final String? link;
  final String? image;

  FeedItem({required this.title, this.description, this.link, this.image});

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      title: json['title'] as String,
      description: json['description'] as String?,
      link: json['link'] as String?,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'link': link,
      'image': image,
    };
  }
}

class Feed {
  final String url;
  final String title;
  final String? description;
  final String? image;
  final List<FeedItem> items;

  Feed({
    required this.url,
    required this.title,
    this.description,
    this.image,
    required this.items,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      url: json['url'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((item) => FeedItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'description': description,
      'image': image,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class ParseFeedsResult {
  final List<Feed> feeds;
  final List<String> errors;

  ParseFeedsResult({required this.feeds, required this.errors});

  factory ParseFeedsResult.fromJson(Map<String, dynamic> json) {
    return ParseFeedsResult(
      feeds: (json['feeds'] as List<dynamic>)
          .map((feed) => Feed.fromJson(feed as Map<String, dynamic>))
          .toList(),
      errors: (json['errors'] as List<dynamic>)
          .map((error) => error as String)
          .toList(),
    );
  }
}

Future<bool> validateFeedURL(String url) async {
  final data = ValidateFeedRequest(url: url);
  final dataBuffer = data.writeToBuffer();

  // Convert Dart Uint8List to C Pointer<Char>
  final Pointer<Char> cData = malloc<Char>(dataBuffer.length);

  // Copy data from Dart buffer to C memory
  for (int i = 0; i < dataBuffer.length; i++) {
    cData[i] = dataBuffer[i];
  }

  try {
    // Call the C function
    final rawValidationResult = _bindings.validate(cData, dataBuffer.length);

    // Convert C Pointer<Char> back to Dart List<int>
    // We need to know the length - assuming it's null-terminated or we need to modify C code to return length
    final List<int> resultData = [];
    int i = 0;
    while (rawValidationResult[i] != 0 && i < 1024) {
      // Safety limit
      resultData.add(rawValidationResult[i]);
      i++;
    }

    final validationResult = ValidateFeedResponse.fromBuffer(resultData);

    return validationResult.valid;
  } finally {
    // Always free the allocated memory
    malloc.free(cData);
  }
}

Future<ParseFeedsResult> parseFeedURLs(List<String> urls) async {
  // Create JSON request
  final requestJson = jsonEncode({'urls': urls});
  final requestBytes = utf8.encode(requestJson);

  // Convert Dart JSON to C Pointer<Char>
  final Pointer<Char> cData = malloc<Char>(requestBytes.length);

  // Copy data from Dart buffer to C memory
  for (int i = 0; i < requestBytes.length; i++) {
    cData[i] = requestBytes[i];
  }

  try {
    // Call the C function
    final rawParseResult = _bindings.parse(cData, requestBytes.length);

    // Convert C Pointer<Char> back to Dart String
    final List<int> resultData = [];
    int i = 0;
    while (rawParseResult[i] != 0 && i < 10240) {
      // Larger safety limit for parse results
      resultData.add(rawParseResult[i]);
      i++;
    }

    // Convert bytes to string and parse JSON
    final resultString = utf8.decode(resultData);
    final resultJson = jsonDecode(resultString) as Map<String, dynamic>;

    return ParseFeedsResult.fromJson(resultJson);
  } finally {
    // Always free the allocated memory
    malloc.free(cData);
  }
}

const String _libName = 'rss_it_library';

final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final RssItLibraryBindings _bindings = RssItLibraryBindings(_dylib);
