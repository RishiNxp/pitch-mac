# Pitch for macOS

Download the ZIP for your processor from [Releases](https://github.com/RishiNxp/pitch-mac/releases). Choose arm64 for Apple Silicon or x64 for Intel. Extract Pitch.app and move it to Applications. The app runs offline and uses the Pitch logo. These builds use an ad hoc signature and are not Apple-notarized.

## Build and release

The repository includes the tested renderer in dist so packaging works from a fresh checkout. After editing the React sources, run npm ci, npm test, and npm run build, then commit the updated dist alongside the source. On a Mac, run bash scripts/package-mac.sh arm64 or bash scripts/package-mac.sh x64. Pushing a version tag builds and publishes both ZIPs through GitHub Actions.
