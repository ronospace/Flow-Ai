#!/bin/bash

SOURCE_SVG="assets/logos/flowai_lovely_icon.svg"
DEST_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"

# Generate all required iOS icon sizes
rsvg-convert -w 29 -h 29 $SOURCE_SVG -o $DEST_DIR/Icon-App-29x29@1x.png
rsvg-convert -w 58 -h 58 $SOURCE_SVG -o $DEST_DIR/Icon-App-29x29@2x.png  
rsvg-convert -w 87 -h 87 $SOURCE_SVG -o $DEST_DIR/Icon-App-29x29@3x.png

rsvg-convert -w 40 -h 40 $SOURCE_SVG -o $DEST_DIR/Icon-App-40x40@1x.png
rsvg-convert -w 80 -h 80 $SOURCE_SVG -o $DEST_DIR/Icon-App-40x40@2x.png
rsvg-convert -w 120 -h 120 $SOURCE_SVG -o $DEST_DIR/Icon-App-40x40@3x.png

rsvg-convert -w 120 -h 120 $SOURCE_SVG -o $DEST_DIR/Icon-App-60x60@2x.png
rsvg-convert -w 180 -h 180 $SOURCE_SVG -o $DEST_DIR/Icon-App-60x60@3x.png

rsvg-convert -w 76 -h 76 $SOURCE_SVG -o $DEST_DIR/Icon-App-76x76@1x.png
rsvg-convert -w 152 -h 152 $SOURCE_SVG -o $DEST_DIR/Icon-App-76x76@2x.png

rsvg-convert -w 167 -h 167 $SOURCE_SVG -o $DEST_DIR/Icon-App-83.5x83.5@2x.png

rsvg-convert -w 1024 -h 1024 $SOURCE_SVG -o $DEST_DIR/Icon-App-1024x1024@1x.png

echo "✅ All iOS icons generated successfully!"
