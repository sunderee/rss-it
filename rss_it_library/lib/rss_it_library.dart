import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:rss_it_library/protos/feed.pb.dart';

import 'rss_it_library_bindings_generated.dart';

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

    // Read the length (first 4 bytes)
    final lengthBytes = <int>[];
    for (int i = 0; i < 4; i++) {
      lengthBytes.add(rawValidationResult[i]);
    }

    // Convert 4 bytes to uint32 (little endian)
    final uint8List = Uint8List.fromList(lengthBytes);
    final byteData = ByteData.view(uint8List.buffer);
    final dataLength = byteData.getUint32(0, Endian.little);

    // Read exactly dataLength bytes after the length prefix
    final List<int> resultData = [];
    for (int i = 4; i < 4 + dataLength; i++) {
      resultData.add(rawValidationResult[i]);
    }

    final validationResult = ValidateFeedResponse.fromBuffer(resultData);

    return validationResult.valid;
  } finally {
    // Always free the allocated memory
    malloc.free(cData);
  }
}

Future<ParseFeedsResponse> parseFeedURLs(List<String> urls) async {
  // Create protobuf request
  final data = ParseFeedsRequest(urls: urls);
  final dataBuffer = data.writeToBuffer();

  // Convert Dart Uint8List to C Pointer<Char>
  final Pointer<Char> cData = malloc<Char>(dataBuffer.length);

  // Copy data from Dart buffer to C memory
  for (int i = 0; i < dataBuffer.length; i++) {
    cData[i] = dataBuffer[i];
  }

  try {
    // Call the C function
    final rawParseResult = _bindings.parse(cData, dataBuffer.length);

    // Read the length (first 4 bytes)
    final lengthBytes = <int>[];
    for (int i = 0; i < 4; i++) {
      lengthBytes.add(rawParseResult[i]);
    }

    // Convert 4 bytes to uint32 (little endian)
    final uint8List = Uint8List.fromList(lengthBytes);
    final byteData = ByteData.view(uint8List.buffer);
    final dataLength = byteData.getUint32(0, Endian.little);

    // Read exactly dataLength bytes after the length prefix
    final List<int> resultData = [];
    for (int i = 4; i < 4 + dataLength; i++) {
      resultData.add(rawParseResult[i]);
    }

    // Parse protobuf response
    final parseResult = ParseFeedsResponse.fromBuffer(resultData);

    return parseResult;
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
