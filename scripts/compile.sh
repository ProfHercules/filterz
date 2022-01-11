#!/bin/bash
rm -rf build
./scripts/tidy.sh

flutter build apk --release --obfuscate --split-debug-info=./debug --split-per-abi &&
flutter build ios --release --obfuscate --split-debug-info=./debug &&
say "Finished compiling" ||
say "Compile failed"

