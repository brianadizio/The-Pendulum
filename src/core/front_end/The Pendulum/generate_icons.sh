#!/bin/bash

# Path to the source icon
SOURCE_ICON="/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/src/core/Fresh Copy of The Pendulum/The Pendulum/AppIcon1024.png"

# Path to output directory
OUTPUT_DIR="/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/src/core/Fresh Copy of The Pendulum/The Pendulum/AppIconSizes"

# Make sure output directory exists
mkdir -p "$OUTPUT_DIR"

# Array of required sizes
SIZES=(16 20 29 32 40 48 50 55 57 58 60 64 66 72 76 80 87 88 92 100 102 114 120 128 144 152 167 172 180 196 216 256 512 1024)

# Generate all sizes using sips
for size in "${SIZES[@]}"; do
  echo "Generating $size x $size icon..."
  sips -Z $size "$SOURCE_ICON" --out "$OUTPUT_DIR/$size.png"
done

echo "All icons generated in $OUTPUT_DIR"

# Copy the icons to the AppIcon.appiconset directory
APPICONSET_DIR="/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/src/core/Fresh Copy of The Pendulum/The Pendulum/The Pendulum/Assets.xcassets/AppIcon.appiconset"

# Copy the 1024x1024 icon to the appiconset directory
cp "$OUTPUT_DIR/1024.png" "$APPICONSET_DIR/AppIcon1024.png"

echo "Copied 1024x1024 icon to $APPICONSET_DIR"
echo "Done!"