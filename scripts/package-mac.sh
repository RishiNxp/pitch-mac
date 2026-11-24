#!/bin/bash
set -euo pipefail
arch=${1:?Specify arm64 or x64}
case "$arch" in arm64|x64) ;; *) exit 2 ;; esac
mode=${2:-trusted}
case "$mode:$arch" in trusted:*|preview:arm64) ;; *) echo "Invalid packaging mode" >&2; exit 2 ;; esac
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
if [[ "$mode" == preview ]]; then
  test "$(uname -m)" = arm64
  lipo "$app/Contents/MacOS/Electron" -verify_arch arm64
  /usr/libexec/PlistBuddy -c 'Set :CFBundleShortVersionString 1.2.0' "$plist"
  /usr/libexec/PlistBuddy -c 'Set :CFBundleVersion 12003' "$plist"
  codesign --force --deep --sign - "$app"
  codesign --verify --deep --strict "$app"
  ditto -c -k --keepParent "$app" Pitch-macOS-arm64.zip
  exit 0
fi
: "${MAC_CERT_P12_BASE64:?Configure Developer ID Application signing certificate}"
: "${MAC_CERT_PASSWORD:?Configure certificate password}"
: "${APPLE_API_KEY_BASE64:?Configure notarization API private key}"
: "${APPLE_API_KEY_ID:?Configure notarization key ID}"
: "${APPLE_API_ISSUER:?Configure notarization issuer}"
umask 077
keychain="$work/pitch.keychain-db"
password=$(openssl rand -hex 32)
security create-keychain -p "$password" "$keychain"
security unlock-keychain -p "$password" "$keychain"
security set-keychain-settings -lut 3600 "$keychain"
printf '%s' "$MAC_CERT_P12_BASE64" | base64 -D > "$work/cert.p12"
security import "$work/cert.p12" -k "$keychain" -P "$MAC_CERT_PASSWORD" -T /usr/bin/codesign
security set-key-partition-list -S apple-tool:,apple: -s -k "$password" "$keychain" >/dev/null
identity=$(security find-identity -v -p codesigning "$keychain" | sed -n 's/.*"\(Developer ID Application:[^"]*\)".*/\1/p' | head -1)
test -n "$identity"
npx --yes --package=@electron/osx-sign@1.3.3 electron-osx-sign "$app" --identity="$identity" --keychain="$keychain" --platform=darwin --type=distribution
codesign --verify --deep --strict --verbose=2 "$app"
ditto -c -k --keepParent "$app" "$work/submission.zip"
printf '%s' "$APPLE_API_KEY_BASE64" | base64 -D > "$work/key.p8"
xcrun notarytool submit "$work/submission.zip" --key "$work/key.p8" --key-id "$APPLE_API_KEY_ID" --issuer "$APPLE_API_ISSUER" --wait --output-format json > "$work/submission.json"
node -e 'const r=require(process.argv[1]); console.log("Apple notarization:",r.id,r.status); if(r.status!=="Accepted")process.exit(1)' "$work/submission.json"
xcrun stapler staple "$app"
xcrun stapler validate "$app"
spctl --assess --type execute --verbose=4 "$app"
ditto -c -k --keepParent "$app" "Pitch-macOS-$arch.zip"
