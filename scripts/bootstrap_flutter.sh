#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter CLI not found. Install Flutter SDK and re-run this script." >&2
  exit 1
fi

flutter --version
flutter create . --project-name vidleo --platforms=android
flutter pub get

echo "Flutter bootstrap complete."
