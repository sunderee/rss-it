# RSSit

A modern, lightweight, and open-source RSS reader built with Flutter.

## Usage

Prerequisites: you will have to perform the following steps:

1. In the `rss_it_library/src` directory, install necessary Go dependencies
2. Run the `rss_it_library/build.sh` Bash script in order to produce Android and iOS binaries and compile message definitions in Go and Dart from `.proto` files
3. Install dependencies for the application using `flutter pub get`.

You can find a Makefile which contains instructions on cleanups, running the app on Android/iOS, and building the application for release.

## Notes

RSSit uses `gofeed` (Go-based library) for validating and parsing RSS/Atom/JSON feeds. This is facilitated by the FFI Flutter plugin `rss_it_library`, which uses protocol buffers for efficient data serialization/deserialization.

This application was developed as part of an experiment to prove/disprove the practicality of Go for the development of FFI Flutter plugins, and as such, is more of an proof-of-concept rather than an actual production-grade application. Because of that, you won't see any tests, nor will you see much documentation in the codebase. Obviously I'm willing to change that in the future, but for now, I'm leaving the application as-is.

## License

The application is open-sourced under the MIT license.