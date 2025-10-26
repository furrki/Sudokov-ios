#!/bin/bash

# Resize iPhone screenshots to iPad 13" (2048x2732 portrait)
# Usage: ./generate_ipad_screenshots.sh path/to/iphone/screenshots

INPUT_DIR="$1"
OUTPUT_DIR="fastlane/screenshots/iPad-13"

if [ -z "$INPUT_DIR" ]; then
  echo "Usage: $0 <input_directory>"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# iPad 13" size: 2048x2732 (portrait)
TARGET_WIDTH=2048
TARGET_HEIGHT=2732

for img in "$INPUT_DIR"/*.png; do
  if [ -f "$img" ]; then
    filename=$(basename "$img")
    echo "Processing $filename..."

    # Resize with letterboxing to maintain aspect ratio
    sips -z $TARGET_HEIGHT $TARGET_WIDTH "$img" --out "$OUTPUT_DIR/$filename" --padColor FFFFFF
  fi
done

echo "Done! Screenshots saved to $OUTPUT_DIR"
