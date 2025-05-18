import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import 'rss_it_library_bindings_generated.dart';

Future<bool> validateFeedURL(String url) async {
  final cURL = url.toNativeUtf8().cast<Char>();
  final validationResult = await Isolate.run(
    () => _bindings.validateFeedURL(cURL),
  );

  malloc.free(cURL);
  return validationResult;
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
