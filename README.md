# Pitch for macOS

## Download

Open the [Pitch macOS releases page](https://github.com/RishiNxp/pitch-mac/releases). Download **Pitch-macOS-arm64.zip** for Apple Silicon or **Pitch-macOS-x64.zip** for Intel. Extract the ZIP and move **Pitch.app** to Applications.

The latest public release is v1.0.0. It is ad hoc signed and not notarized, so it does not pass Apple's normal Gatekeeper checks. The updated release workflow will publish a signed and notarized version after valid Apple credentials are configured.

## Build and publish

Building and notarizing macOS applications requires a Mac with Xcode command line tools and an Apple Developer ID Application certificate. The GitHub Actions workflow also needs these repository secrets:

- **MAC_CERT_P12_BASE64** and **MAC_CERT_PASSWORD** for the Developer ID certificate.
- **APPLE_API_KEY_BASE64**, **APPLE_API_KEY_ID**, and **APPLE_API_ISSUER** for Apple notarization.

Clone this repository and review the workflow:

~~~sh
git clone https://github.com/RishiNxp/pitch-mac.git
cd pitch-mac
npm ci
npm test
npm run build
~~~

After pushing the release source to **main**, create a new unused version tag to start the packaging workflow:

~~~sh
git add -A
git commit -m "Describe the macOS update"
git push origin main
git tag v1.1.1
git push origin v1.1.1
~~~

Both processor builds must pass signing, notarization, stapling, and Gatekeeper assessment before the release workflow publishes their ZIP files. You need write access to push to this repository.

## Run the calculator from source

Use Node.js 22.12 or newer and npm. Run **npm run dev** to start the local Vite development server.
