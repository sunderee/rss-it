import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:rss_it_library/protos/feed.pb.dart';

import 'rss_it_library_bindings_generated.dart';

/// Validates a feed URL via the native Go implementation.
/// Throws [RssItLibraryException] when the native side reports a structured error.
Future<bool> validateFeedURL(String url) =>
    Isolate.run<bool>(() => _validateSync(url));

/// Parses one or more feed URLs using the Go runtime with concurrency and sanitisation.
/// Throws [RssItLibraryException] when a fatal (non-partial) error occurs.
Future<ParseFeedsResponse> parseFeedURLs(List<String> urls) =>
    Isolate.run<ParseFeedsResponse>(() => _parseSync(urls));

bool _validateSync(String url) {
  final request = ValidateFeedRequest(url: url);
  final buffer = request.writeToBuffer();
  final responseBytes = _invokeNative(buffer, _bindings.validate);

  final response = ValidateFeedResponse.fromBuffer(responseBytes);
  if (response.hasError()) {
    throw RssItLibraryException('validate', response.error);
  }
  return response.valid;
}

ParseFeedsResponse _parseSync(List<String> urls) {
  final request = ParseFeedsRequest(urls: urls);
  final buffer = request.writeToBuffer();
  final responseBytes = _invokeNative(buffer, _bindings.parse);

  final response = ParseFeedsResponse.fromBuffer(responseBytes);
  if (response.hasFatalError()) {
    throw RssItLibraryException('parse', response.fatalError);
  }
  return response;
}

/// Invokes the provided native FFI function with a request payload, returning the raw response bytes.
Uint8List _invokeNative(
  Uint8List request,
  ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>, int) function,
) {
  final ffi.Pointer<ffi.Char> cRequest = malloc<ffi.Char>(request.length);
  try {
    final view = cRequest.cast<ffi.Uint8>().asTypedList(request.length);
    view.setAll(0, request);

    final ffi.Pointer<ffi.Char> resultPtr = function(cRequest, request.length);
    if (resultPtr == ffi.nullptr) {
      throw RssItLibraryException.internal('invoke', 'Native function returned null pointer');
    }

    return _takeResponseBytes(resultPtr);
  } finally {
    malloc.free(cRequest);
  }
}

/// Copies the length-prefixed native buffer into a Dart [Uint8List] and frees the native memory.
Uint8List _takeResponseBytes(ffi.Pointer<ffi.Char> pointer) {
  try {
    final ffi.Pointer<ffi.Uint8> base = pointer.cast<ffi.Uint8>();
    final headerCopy = Uint8List.fromList(base.asTypedList(4));
    final byteData = ByteData.view(headerCopy.buffer);
    final payloadLength = byteData.getUint32(0, Endian.little);

    final totalLength = 4 + payloadLength;
    final fullCopy = Uint8List.fromList(base.asTypedList(totalLength));
    return Uint8List.fromList(fullCopy.sublist(4));
  } finally {
    _bindings.freeResult(pointer);
  }
}

/// RssItLibraryException exposes structured failure information returned by the native layer.
class RssItLibraryException implements Exception {
  RssItLibraryException(this.operation, this.detail);

  RssItLibraryException.internal(this.operation, String message)
      : detail = ErrorDetail(
          kind: ErrorKind.ERROR_KIND_INTERNAL,
          message: message,
        );

  final String operation;
  final ErrorDetail detail;

  @override
  String toString() {
    final location = detail.hasUrl() && detail.url.isNotEmpty ? ' (${detail.url})' : '';
    return 'RssItLibraryException[$operation]: ${detail.kind.name} - ${detail.message}$location';
  }
}

const String _libName = 'rss_it_library';

final ffi.DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return ffi.DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return ffi.DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return ffi.DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final RssItLibraryBindings _bindings = RssItLibraryBindings(_dylib);
