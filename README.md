# Pitch for macOS

Download the ZIP for your processor from [Releases](https://github.com/RishiNxp/pitch-mac/releases). Choose arm64 for Apple Silicon or x64 for Intel and move the extracted Pitch.app to Applications. Release v1.0.0 used ad hoc signing.

## Release builds

The release workflow builds the calculator, signs the Electron application using Developer ID Application, submits it to Apple for notarization, staples and validates the ticket, and checks Gatekeeper before packaging. A release tag publishes only after both architectures pass.

Configure the repository Actions secrets MAC_CERT_P12_BASE64 (base64 PKCS#12 certificate with private key), MAC_CERT_PASSWORD, APPLE_API_KEY_BASE64 (base64 App Store Connect team API private key), APPLE_API_KEY_ID, and APPLE_API_ISSUER. Provide these through GitHub secret settings. Push a version tag to build a release.
