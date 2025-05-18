#!/bin/bash

set -e

# === CONFIGURATION ===
APP_NAME="The Pendulum"
SCHEME="The Pendulum"
WORKSPACE="The Pendulum.xcworkspace"      # Or use PROJECT="TheMaze.xcodeproj"
SONAR_PROJECT_KEY="The-Pendulum"
DEST="platform=iOS Simulator,name=iPhone 16"
BUILD_DIR="build"
OUTPUT_DIR="coverage"
LCOV_FILE="$OUTPUT_DIR/coverage.lcov"

# === 1. CLEAN + BUILD + TEST ===
echo "🧹 Cleaning previous build..."
xcodebuild clean -scheme "$SCHEME" -workspace "$WORKSPACE"

echo "⚙️ Building and testing with code coverage..."
xcodebuild test \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -destination "$DEST" \
  -derivedDataPath "$BUILD_DIR" \
  -enableCodeCoverage YES \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

# === 2. GENERATE LCOV WITH SLATHER ===
echo "📊 Generating coverage.lcov with Slather..."
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

slather coverage \
  --scheme "$SCHEME" \
  --workspace "$WORKSPACE" \
  --build-directory "$BUILD_DIR" \
  --output-directory "$OUTPUT_DIR" \
  --coverage-format lcov \
  --ignore "Tests/*" \
  --binary-basename "$SCHEME" \
  "$WORKSPACE"

# === 3. RUN SWIFTLINT (optional) ===
echo "📏 Running SwiftLint..."
swiftlint lint --reporter json > swiftlint.json || true

# === 4. RUN SONAR-SCANNER ===
echo "🚀 Running SonarQube analysis..."
sonar-scanner \
  -Dsonar.projectKey="$SONAR_PROJECT_KEY" \
  -Dsonar.sources=./ \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=sqa_67905d13518df2026dd6ce5efb8e4102ac099758 \
  -Dsonar.coverageReportPaths="$LCOV_FILE" \
  -Dsonar.swift.swiftLint.reportPaths=swiftlint.json

echo "✅ SonarQube scan complete!"
