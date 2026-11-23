#!/bin/bash
set -euo pipefail
arch=${1:?Specify arm64 or x64}
case "$arch" in arm64|x64) ;; *) exit 2 ;; esac
version=v45.4.1
asset="electron-$version-darwin-$arch.zip"
base="https://github.com/electron/electron/releases/download/$version"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
curl -fsSL --retry 3 "$base/$asset" -o "$work/$asset"
curl -fsSL --retry 3 "$base/SHASUMS256.txt" -o "$work/checks"
(cd "$work"; awk -v a="$asset" '$2==a || $2=="*"a {print $1 "  " a; found=1} END {if(!found)exit 1}' checks | shasum -a 256 -c -)
ditto -x -k "$work/$asset" "$work/runtime"
app="$work/Pitch.app"
mv "$work/runtime/Electron.app" "$app"
resources="$app/Contents/Resources"
mkdir -p "$resources/app/desktop" "$work/Pitch.iconset"
ditto dist "$resources/app/dist"
cp desktop/main.cjs "$resources/app/desktop/"
cp desktop/application.json "$resources/app/package.json"
rm -f "$resources/default_app.asar"
for size in 16 32 128 256 512; do
  sips -z "$size" "$size" public/pitch-logo.png --out "$work/Pitch.iconset/icon_${size}x${size}.png" >/dev/null
  double=$((size * 2))
  sips -z "$double" "$double" public/pitch-logo.png --out "$work/Pitch.iconset/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$work/Pitch.iconset" -o "$resources/electron.icns"
plist="$app/Contents/Info.plist"
for key in CFBundleName CFBundleDisplayName; do /usr/libexec/PlistBuddy -c "Set :$key Pitch" "$plist"; done
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier com.rishinxp.pitch' "$plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleIconFile electron.icns' "$plist"
codesign --force --deep --sign - "$app"
codesign --verify --deep --strict "$app"
ditto -c -k --keepParent "$app" "Pitch-macOS-$arch.zip"
