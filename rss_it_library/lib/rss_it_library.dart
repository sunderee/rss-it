import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:rss_it_library/models/parse_feed_model.dart';

import 'rss_it_library_bindings_generated.dart';

Future<bool> validateFeedURL(String url) async {
  final cURL = url.toNativeUtf8().cast<Char>();
  final validationResult = await Isolate.run(() => _bindings.validate(cURL));

  malloc.free(cURL);
  return validationResult;
}

Future<ParseFeedResponseModel> parseFeedURLs(List<String> urls) async {
  final request = ParseFeedRequestModel(urls: urls);
  final requestJson = jsonEncode(request.toJson());

  final cURLs = requestJson.toNativeUtf8().cast<Char>();
  final parseResult = await Isolate.run(() => _bindings.parse(cURLs));
  final parseResultString = parseResult.cast<Utf8>().toDartString();

  malloc.free(cURLs);
  malloc.free(parseResult);

  return Isolate.run(
    () => ParseFeedResponseModel.fromJson(
      jsonDecode(parseResultString) as Map<String, dynamic>,
    ),
  );
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
