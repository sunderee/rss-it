# rss_it_library

`rss_it_library` is a Flutter FFI plugin backed by a Go runtime for high-throughput RSS/Atom parsing.  The library builds on top of [`gofeed`](https://github.com/mmcdole/gofeed) and communicates with Dart through protobuf-defined messages.

## Architecture Notes

- **Go entry points** – The exported `validate` and `parse` functions live in `src/main.go`. They unmarshal protobuf requests, delegate to the validator/parser, and always return a length-prefixed protobuf envelope. Any serialisation failure is folded into a `ErrorDetail` payload so the Dart layer can surface a structured error instead of falling back to raw strings.
- **Concurrency** – `RSSParser` uses an `errgroup.Group` with a configurable concurrency limit to fan out feed downloads. Each request runs with a deadline so runaway feeds cannot stall the bridge. The Dart side executes FFI calls on background isolates via `Isolate.run`, keeping the UI responsive.
- **Error propagation** – Protobuf messages now contain `ErrorDetail` objects with a `kind`, `message`, and optional `url`. The Dart wrapper throws a `RssItLibraryException` whenever the Go layer indicates a fatal condition (validation failure or parse fatal error). Partial parse results are still returned with `errors` populated for per-feed issues.
- **Memory management** – Responses are allocated with `C.malloc` and must be released. The Go layer exports `free_result`, and the Dart binding mirrors it via `_bindings.freeResult`. Always copy the bytes before calling `freeResult` to avoid use-after-free bugs.

## Build Pipeline

The top-level `build.sh` coordinates native builds and code generation:

1. Regenerates Go protobuf types (`src/build-protos.sh`) – ensures `protoc` and `protoc-gen-go` are on `PATH`.
2. Builds Android (`build-android.sh`) and iOS (`build-ios.sh`) artefacts with CGO enabled.
3. Optionally regenerates Dart FFI bindings via `ffigen` and protobuf stubs if the Flutter toolchain is available.

Example:

```bash
cd rss_it_library
./build.sh release
```

Pass `debug` or `release` to forward the desired build mode to the platform scripts.

## Testing

- **Go** – run `go test ./src/...` from `rss_it_library`. Tests cover sanitisation, concurrency semantics, and the new error classification helpers.
- **Dart** – run `dart test` (or `flutter test`) inside `rss_it_library` once the Dart/Flutter SDK is installed. The test suite exercises protobuf round-trips and the `RssItLibraryException` surface.

Remember to install the protobuf compiler (`protoc`) if you intend to regenerate code locally.

## Dart API Highlights

- `Future<bool> validateFeedURL(String url)` – validates a single feed, throwing `RssItLibraryException` if the Go layer reports a structured error.
- `Future<ParseFeedsResponse> parseFeedURLs(List<String> urls)` – parses feeds concurrently. Fatal errors throw, while per-feed issues are recorded in `response.errors`.
- `RssItLibraryException` – exposes the `ErrorDetail` returned by Go. The `detail.kind` enum enables consumer code to differentiate between network, parsing, validation, and internal failures.

## Adding New Protos

1. Update the schemas in `src/proto/feed.proto` and `lib/protos/feed.proto`.
2. Run `./build.sh` (or directly invoke `src/build-protos.sh` and `protoc --dart_out=lib/protos feed.proto`).
3. Commit the regenerated `feed.pb.go` and `lib/protos/feed.pb.dart` artefacts.

## Further Reading

- `src/parser.go` – concurrency model and sanitisation helpers.
- `src/validator.go` – timeout-aware validation logic.
- `lib/rss_it_library.dart` – isolate-aware FFI bridge with structured error surfacing.
