#!/bin/sh
# ci_post_clone.sh
# Runs after Xcode Cloud clones the repository.
# Resolves SPM packages and any environment setup.

set -e

echo "=== Xcode Cloud Post-Clone ==="
echo "Working directory: $(pwd)"
echo "Xcode version: $(xcodebuild -version)"

# SPM packages are resolved automatically by Xcode Cloud,
# but if any local package paths need adjustment, do it here.

# The project lives at a nested path within the repo:
# src/core/front_end/The Pendulum 2.0/The Pendulum 2.0.xcodeproj

echo "=== Post-Clone Complete ==="
