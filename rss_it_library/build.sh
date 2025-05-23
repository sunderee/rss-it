#!/usr/bin/env bash
cd src || exit
./build-android.sh
./build-ios.sh
cd ..

flutter clean
flutter pub get
dart run ffigen --config ffigen.yaml

cd lib/proto || exit
protoc --dart_out=. feed.proto

echo "DONE"