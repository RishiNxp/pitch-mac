# Pitch for macOS

## Download the current Apple Silicon preview

1. Choose Apple menu → **About This Mac**. A **Chip** entry such as Apple M1, M2, M3 or M4 identifies an Apple Silicon Mac. For an Intel machine, see [older Intel downloads](https://github.com/RishiNxp/pitch-mac/releases/tag/v1.0.0).
2. Open the [Apple Silicon preview release](https://github.com/RishiNxp/pitch-mac/releases/tag/preview-1.2.0-2). Under **Assets**, download **Pitch-macOS-arm64.zip**. The ZIP contains the application. The separate source archives are for developers.
3. In Finder, open **Downloads** and double-click the ZIP if Safari has not already expanded it. Drag **Pitch.app** into **Applications**. If replacing an earlier Pitch, first open the old app and use **Save file** to back up your layout, then quit it.
4. Open **Applications → Pitch**. Choose **Start a layout** on the welcome screen. The current calculator includes the collapsible RPM board, motion playback, catalog belt fitting, wheel-speed and torque estimates.
5. To try it offline, create a layout, save it, quit Pitch, disconnect from the network, reopen Pitch, and open the saved file. To uninstall, quit and move Pitch.app from Applications to Trash. Keep your exported layouts.

This preview is ad hoc signed. It has no Apple Developer ID signature or Apple notarization. macOS or a managed-device policy may block launch. If that happens, use [Pitch in your browser](https://rishinxp.github.io/pitch-web/). See [Apple’s guide to opening downloaded apps](https://support.apple.com/en-us/102445). An automated launch on the build runner does not test every macOS version or simulate a browser download with Gatekeeper.

**Optional integrity check.** Download SHA256SUMS.txt from the same release. With both files in Downloads, run:

~~~sh
cd ~/Downloads
shasum -a 256 -c SHA256SUMS.txt
~~~

## Build on an Apple Silicon Mac

Install Node.js 22.12 or newer and the Xcode command line tools. From Terminal:

~~~sh
git clone https://github.com/RishiNxp/pitch-mac.git
cd pitch-mac
npm ci
npm test
npm run build
bash scripts/package-mac.sh arm64 preview
~~~

This creates Pitch-macOS-arm64.zip in the repository root. Downloading the Electron runtime requires internet during packaging. End users only need the ZIP.

## Maintainer release steps

- **Tester preview:** Update the shared frontend on main, review the application version in the packaging script, then push an unused tag matching preview-* on the tested commit. The Apple Silicon workflow tests the frontend, builds on macOS arm64, verifies the executable architecture and signature, launches the extracted ZIP, checks for the welcome button and publishes a GitHub prerelease with the ZIP and SHA-256 checksum.
- **Trusted distribution:** Configure MAC_CERT_P12_BASE64 and MAC_CERT_PASSWORD for the Developer ID Application certificate, plus APPLE_API_KEY_BASE64, APPLE_API_KEY_ID and APPLE_API_ISSUER for notarization. Push an unused v-prefixed version tag. The separate trusted workflow signs, notarizes, staples and assesses both architectures before publishing.
- **Before announcing support:** Download the actual published ZIP on a tester Mac. Record the chip, macOS version, Gatekeeper result, offline calculation, save/reopen result and behavior when replacing the previous app.
