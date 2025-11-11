#!/bin/bash

set -e

# === CONFIGURATION ===
APP_NAME="The Pendulum"
SCHEME="The Pendulum"
WORKSPACE="The Pendulum.xcworkspace"
SONAR_PROJECT_KEY="The-Pendulum"
DEST="platform=iOS Simulator,name=iPhone 16"
BUILD_DIR="build"
OUTPUT_DIR="coverage"
LCOV_FILE="$OUTPUT_DIR/coverage.lcov"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_DIR="${OUTPUT_DIR}/report_${TIMESTAMP}"

# === SETUP ===
echo "🔍 Starting Code Coverage Analysis for The Pendulum..."
echo "=================================================="
echo "Timestamp: $TIMESTAMP"
echo ""

# Create output directories
mkdir -p "$REPORT_DIR"

# === 1. CLEAN + BUILD + TEST ===
echo "🧹 Cleaning previous build..."
xcodebuild clean -scheme "$SCHEME" -workspace "$WORKSPACE" -quiet

echo "⚙️ Building and testing with code coverage..."
xcodebuild test \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -destination "$DEST" \
  -derivedDataPath "$BUILD_DIR" \
  -enableCodeCoverage YES \
  -resultBundlePath "$REPORT_DIR/TestResults.xcresult" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | tee "$REPORT_DIR/test_output.log" | grep -E "(Test Suite|Test Case|Executed|passed|failed)" || true

# Check if tests succeeded
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "❌ Tests failed! Check the log at $REPORT_DIR/test_output.log"
    exit 1
fi

echo ""
echo "✅ Tests completed successfully!"
echo ""

# === 2. GENERATE MULTIPLE COVERAGE FORMATS ===
echo "📊 Generating coverage reports..."

# Generate LCOV with Slather
if command -v slather &> /dev/null; then
    echo "📊 Generating coverage.lcov with Slather..."
    slather coverage \
      --scheme "$SCHEME" \
      --workspace "$WORKSPACE" \
      --build-directory "$BUILD_DIR" \
      --output-directory "$REPORT_DIR" \
      --coverage-format lcov \
      --ignore "Tests/*" \
      --ignore "*.generated.swift" \
      --binary-basename "$SCHEME" \
      "$WORKSPACE"
    
    # Also generate HTML report with Slather
    echo "📊 Generating HTML report with Slather..."
    slather coverage \
      --scheme "$SCHEME" \
      --workspace "$WORKSPACE" \
      --build-directory "$BUILD_DIR" \
      --output-directory "$REPORT_DIR/html_slather" \
      --coverage-format html \
      --ignore "Tests/*" \
      --ignore "*.generated.swift" \
      --binary-basename "$SCHEME" \
      "$WORKSPACE"
else
    echo "⚠️ Slather not found. Install with: gem install slather"
fi

# Generate coverage report using xcrun llvm-cov
echo "📊 Generating coverage report with llvm-cov..."

# Find the coverage profdata file
PROFDATA=$(find "$BUILD_DIR" -name "*.profdata" | head -n 1)
if [ -z "$PROFDATA" ]; then
    echo "❌ Error: Coverage data not found"
    exit 1
fi

# Find the binary
BINARY=$(find "$BUILD_DIR" -path "*/$SCHEME.app/$SCHEME" | head -n 1)
if [ -z "$BINARY" ]; then
    echo "❌ Error: Binary not found"
    exit 1
fi

# Text report
xcrun llvm-cov report \
    "$BINARY" \
    -instr-profile="$PROFDATA" \
    -ignore-filename-regex='.*Tests.*' \
    -ignore-filename-regex='.*\.generated\.swift' \
    > "$REPORT_DIR/coverage_summary.txt"

# Show summary
echo ""
echo "📈 Coverage Summary:"
echo "==================="
cat "$REPORT_DIR/coverage_summary.txt" | tail -n 20

# HTML report with llvm-cov
echo "📋 Generating detailed HTML coverage report..."
xcrun llvm-cov show \
    "$BINARY" \
    -instr-profile="$PROFDATA" \
    -use-color \
    -format=html \
    -output-dir="$REPORT_DIR/html_llvm" \
    -ignore-filename-regex='.*Tests.*' \
    -ignore-filename-regex='.*\.generated\.swift'

# JSON report for analysis
xcrun llvm-cov export \
    "$BINARY" \
    -instr-profile="$PROFDATA" \
    -format=lcov \
    -ignore-filename-regex='.*Tests.*' \
    -ignore-filename-regex='.*\.generated\.swift' \
    > "$REPORT_DIR/coverage_llvm.lcov"

# === 3. RUN SWIFTLINT ===
if command -v swiftlint &> /dev/null; then
    echo "📏 Running SwiftLint..."
    swiftlint lint --reporter json > "$REPORT_DIR/swiftlint.json" || true
    swiftlint lint --reporter html > "$REPORT_DIR/swiftlint.html" || true
else
    echo "⚠️ SwiftLint not found. Install with: brew install swiftlint"
fi

# === 4. CREATE REPORT INDEX ===
cat > "$REPORT_DIR/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>The Pendulum - Code Coverage Report</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 20px; background: #f5f5f7; }
        .container { max-width: 1000px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #1d1d1f; margin-bottom: 10px; }
        h2 { color: #333; margin-top: 30px; }
        .info { background: #f0f0f2; padding: 15px; border-radius: 8px; margin: 20px 0; }
        .info strong { color: #1d1d1f; }
        .links { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 15px; margin: 20px 0; }
        .link { background: #007AFF; color: white; padding: 15px; border-radius: 8px; text-decoration: none; transition: all 0.3s; }
        .link:hover { background: #0051D5; transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,122,255,0.3); }
        .link-secondary { background: #f0f0f2; color: #1d1d1f; }
        .link-secondary:hover { background: #e0e0e2; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin: 20px 0; }
        .stat { background: #f0f0f2; padding: 20px; border-radius: 8px; text-align: center; }
        .stat-value { font-size: 2em; font-weight: bold; color: #007AFF; }
        .stat-label { color: #666; margin-top: 5px; }
        .timestamp { color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎯 The Pendulum - Code Coverage Report</h1>
        <p class="timestamp">Generated: $(date)</p>
        
        <div class="info">
            <strong>Project:</strong> $APP_NAME<br>
            <strong>Scheme:</strong> $SCHEME<br>
            <strong>Report ID:</strong> $TIMESTAMP
        </div>
        
        <h2>📊 Coverage Reports</h2>
        <div class="links">
            <a href="html_llvm/index.html" class="link">
                <strong>LLVM Coverage Report</strong><br>
                <small>Detailed line-by-line coverage</small>
            </a>
            <a href="html_slather/index.html" class="link">
                <strong>Slather HTML Report</strong><br>
                <small>Alternative coverage visualization</small>
            </a>
            <a href="coverage_summary.txt" class="link link-secondary">
                <strong>Text Summary</strong><br>
                <small>Quick overview in text format</small>
            </a>
        </div>
        
        <h2>🔧 Analysis Files</h2>
        <div class="links">
            <a href="coverage.lcov" class="link link-secondary">
                <strong>LCOV Report</strong><br>
                <small>For SonarQube integration</small>
            </a>
            <a href="swiftlint.html" class="link link-secondary">
                <strong>SwiftLint Report</strong><br>
                <small>Code style analysis</small>
            </a>
            <a href="test_output.log" class="link link-secondary">
                <strong>Test Output Log</strong><br>
                <small>Complete test execution log</small>
            </a>
        </div>
        
        <h2>📈 Quick Stats</h2>
        <div class="stats" id="stats">
            <div class="stat">
                <div class="stat-value">-</div>
                <div class="stat-label">Line Coverage</div>
            </div>
            <div class="stat">
                <div class="stat-value">-</div>
                <div class="stat-label">Function Coverage</div>
            </div>
            <div class="stat">
                <div class="stat-value">-</div>
                <div class="stat-label">Test Count</div>
            </div>
        </div>
    </div>
    
    <script>
        // Extract stats from coverage summary
        fetch('coverage_summary.txt')
            .then(response => response.text())
            .then(text => {
                const lines = text.split('\\n');
                const totalLine = lines.find(line => line.includes('TOTAL'));
                if (totalLine) {
                    const parts = totalLine.split(/\\s+/);
                    if (parts.length >= 10) {
                        document.querySelector('#stats .stat:nth-child(1) .stat-value').textContent = parts[9] || '-';
                        document.querySelector('#stats .stat:nth-child(2) .stat-value').textContent = parts[6] || '-';
                    }
                }
            })
            .catch(() => console.log('Could not load stats'));
    </script>
</body>
</html>
EOF

# === 5. COPY LCOV FILE TO STANDARD LOCATION ===
if [ -f "$REPORT_DIR/coverage.lcov" ]; then
    cp "$REPORT_DIR/coverage.lcov" "$LCOV_FILE"
elif [ -f "$REPORT_DIR/coverage_llvm.lcov" ]; then
    cp "$REPORT_DIR/coverage_llvm.lcov" "$LCOV_FILE"
fi

# === 6. RUN SONAR-SCANNER (if configured) ===
if [ -f "sonar-project.properties" ] && command -v sonar-scanner &> /dev/null; then
    echo "🚀 Running SonarQube analysis..."
    SONAR_TOKEN=$SONAR_TOKEN_The_Pendulum sonar-scanner \
        -Dsonar.organization=brianadizio \
        -Dsonar.projectKey=brianadizio_The-Pendulum \
        -Dsonar.sources=. \
        -Dsonar.host.url=https://sonarcloud.io
    
    #sonar-scanner \
      -Dsonar.projectKey="$SONAR_PROJECT_KEY" \
      -Dsonar.sources=./ \
      -Dsonar.coverageReportPaths="$LCOV_FILE" \
      -Dsonar.swift.swiftLint.reportPaths="$REPORT_DIR/swiftlint.json" || echo "⚠️ SonarQube analysis failed"
else
    echo "ℹ️ Skipping SonarQube analysis (not configured or sonar-scanner not found)"
fi

# === 7. OPEN REPORT ===
echo ""
echo "🌐 Opening coverage report in browser..."
open "$REPORT_DIR/index.html"

# === 8. CREATE SYMLINK TO LATEST ===
ln -sfn "$REPORT_DIR" "${OUTPUT_DIR}/latest"

# === 9. CLEANUP OLD REPORTS ===
echo "🗄️ Archiving old reports (keeping last 10)..."
ls -dt ${OUTPUT_DIR}/report_* 2>/dev/null | tail -n +11 | xargs rm -rf 2>/dev/null || true

# === SUMMARY ===
echo ""
echo "✨ Code Coverage Analysis Complete!"
echo "===================================="
echo "📁 Report saved to: $REPORT_DIR"
echo "🔗 Latest report: ${OUTPUT_DIR}/latest"
echo ""
echo "💡 Next steps:"
echo "  1. Review the HTML coverage report for uncovered code"
echo "  2. Add tests for critical uncovered sections"
echo "  3. Run this script regularly to track progress"
echo "  4. Configure SonarQube for continuous analysis"
echo ""
echo "🎉 Done!"
