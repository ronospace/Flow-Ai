#!/bin/bash

SOURCE_SVG="assets/logos/flowai_lovely_icon.svg"

# Generate Android icons
rsvg-convert -w 48 -h 48 $SOURCE_SVG -o android/app/src/main/res/mipmap-mdpi/ic_launcher.png
rsvg-convert -w 72 -h 72 $SOURCE_SVG -o android/app/src/main/res/mipmap-hdpi/ic_launcher.png
rsvg-convert -w 96 -h 96 $SOURCE_SVG -o android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
rsvg-convert -w 144 -h 144 $SOURCE_SVG -o android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
rsvg-convert -w 192 -h 192 $SOURCE_SVG -o android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

# Also generate launcher_icon.png files
rsvg-convert -w 48 -h 48 $SOURCE_SVG -o android/app/src/main/res/mipmap-mdpi/launcher_icon.png
rsvg-convert -w 72 -h 72 $SOURCE_SVG -o android/app/src/main/res/mipmap-hdpi/launcher_icon.png
rsvg-convert -w 96 -h 96 $SOURCE_SVG -o android/app/src/main/res/mipmap-xhdpi/launcher_icon.png
rsvg-convert -w 144 -h 144 $SOURCE_SVG -o android/app/src/main/res/mipmap-xxhdpi/launcher_icon.png
rsvg-convert -w 192 -h 192 $SOURCE_SVG -o android/app/src/main/res/mipmap-xxxhdpi/launcher_icon.png

echo "✅ All Android icons generated successfully!"
