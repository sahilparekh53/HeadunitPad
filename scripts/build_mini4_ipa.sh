#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-$ROOT_DIR/.build/Mini4IPA}"
DERIVED_DATA="$ROOT_DIR/.build/Mini4DerivedData"

if [[ "$(uname -s)" != Darwin ]]; then
  echo 'This build needs a Mac with Xcode; use the Build iPad mini 4 workflow from Windows.' >&2
  exit 1
fi

cd "$ROOT_DIR"
xcodegen generate --spec project-mini4.yml
pod install --project-directory=mini4
xcodebuild build \
  -workspace mini4/HeadunitPadMini4.xcworkspace \
  -scheme HeadunitPadMini4 -configuration Release \
  -sdk iphoneos -destination 'generic/platform=iOS' \
  -derivedDataPath "$DERIVED_DATA" \
  ARCHS=arm64 ONLY_ACTIVE_ARCH=NO \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO

APP="$DERIVED_DATA/Build/Products/Release-iphoneos/HeadunitPad.app"
BINARY="$APP/HeadunitPad"
test -f "$BINARY"
test "$(/usr/libexec/PlistBuddy -c 'Print :MinimumOSVersion' "$APP/Info.plist")" = '15.0'
lipo "$BINARY" -verify_arch arm64
if otool -L "$BINARY" | grep -qiE 'USBHostKit|libusb'; then
  echo 'Wireless app unexpectedly links a USB host library.' >&2
  exit 1
fi

# Keep this unsigned: AltStore/Sideloadly will apply the user's normal signature.
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/headunitpad-mini4.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT
mkdir -p "$OUTPUT_DIR" "$WORK_DIR/Payload"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"
cp -R "$APP" "$WORK_DIR/Payload/HeadunitPad.app"
IPA="$OUTPUT_DIR/HeadunitPad-Mini4-unsigned.ipa"
rm -f "$IPA"
(cd "$WORK_DIR" && zip -qry "$IPA" Payload)
python3 "$ROOT_DIR/scripts/verify_mini4_ipa.py" "$IPA"
echo "Unsigned IPA for sideloading: $IPA"
