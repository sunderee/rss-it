import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:rss_it_library/protos/feed.pb.dart';

import 'rss_it_library_bindings_generated.dart';

Future<bool> validateFeedURL(String url) async {
  final data = ValidateFeedRequest(url: url);
  final dataBuffer = data.writeToBuffer();

  final rawValidationResult = _bindings.validate(dataBuffer, dataBuffer.length);
  final validationResult = ValidateFeedResponse.fromBuffer(rawValidationResult);

  return validationResult.valid;
}

Future<void> parseFeedURLs(List<String> urls) async {
  // final request = ParseFeedsRequest(urls: urls);
  // final requestJson = jsonEncode(request.toJson());

  // final cURLs = requestJson.toNativeUtf8().cast<Char>();
  // final parseResult = await Isolate.run(() => _bindings.parse(cURLs));
  // final parseResultString = parseResult.cast<Utf8>().toDartString();

  // malloc.free(cURLs);
  // malloc.free(parseResult);

  // logger.info('Parse result: $parseResultString');
  // return Isolate.run(
  //   () => ParseFeedResponseModel.fromJson(
  //     jsonDecode(parseResultString) as Map<String, dynamic>,
  //   ),
  // );
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
