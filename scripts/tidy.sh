#!/bin/bash
rm -rf build
flutter clean &&
git clean -fd -X &&
flutter pub get && 
flutter pub run build_runner build --delete-conflicting-outputs &&
flutter pub run import_sorter:main &&
say "Tidied up" ||
say "Tidy failed"