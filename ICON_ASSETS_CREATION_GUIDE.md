# Icon Assets Creation Guide: Flow Ai Branding

## Overview
Complete guide for creating new Flow Ai branded icons and updating all app icon references.

## 🎨 Step 1: Design Requirements

### Brand Guidelines
- **App Name:** Flow Ai
- **Primary Colors:** 
  - Primary Blue: #2563EB
  - Secondary Pink: #EC4899
  - Accent Purple: #8B5CF6
  - Background: #FFFFFF / #000000

### Icon Design Specifications
- **Style:** Modern, clean, medical/health focused
- **Shape:** Rounded square with subtle corner radius
- **Concept:** Flow/wave elements representing feminine health cycles
- **Typography:** Clean, sans-serif if text is included

### Technical Requirements
- **Format:** Vector (SVG) source + PNG exports
- **Background:** Transparent or solid color
- **Safe area:** 20% margin from edges
- **Color modes:** Light and dark variants

## 📐 Step 2: Icon Size Requirements

### iOS App Icons
```
20x20    - iPhone Notification (iOS 7-14)
29x29    - iPhone Settings (iOS 5,6), iPad Settings (iOS 5-12)
40x40    - iPhone Spotlight (iOS 7-14)
58x58    - iPhone Settings @2x (iOS 5-12)
60x60    - iPhone App Icon (iOS 7-12)
76x76    - iPad App Icon (iOS 7-13)
80x80    - iPhone Spotlight @2x (iOS 7-14)
87x87    - iPhone Settings @3x (iOS 5-12)
120x120  - iPhone App Icon @2x (iOS 7-14)
152x152  - iPad App Icon @2x (iOS 7-12)
167x167  - iPad App Icon @2x (iPad Pro 12.9")
180x180  - iPhone App Icon @3x (iOS 7-14)
1024x1024 - App Store
```

### Android App Icons
```
48x48    - MDPI (Medium density ~160dpi)
72x72    - HDPI (High density ~240dpi)
96x96    - XHDPI (Extra-high density ~320dpi)
144x144  - XXHDPI (Extra-extra-high density ~480dpi)
192x192  - XXXHDPI (Extra-extra-extra-high density ~640dpi)
512x512  - Play Store
```

### macOS App Icons
```
16x16    - Menu bar, dock (small)
32x32    - Menu bar, dock (large)
128x128  - Application folder
256x256  - Application folder (retina)
512x512  - Application folder (retina)
1024x1024 - App Store
```

### Web App Icons
```
16x16    - Browser favicon
32x32    - Browser favicon (retina)
192x192  - Android Chrome
512x512  - iOS Safari, Android Chrome (large)
```

## 🛠️ Step 3: Asset Creation

### Create Source SVG Files
1. **Create master SVG icons:**
```
assets/logos/flowai_icon.svg           # Primary app icon
assets/logos/flowai_lovely_icon.svg    # Decorative version
assets/logos/flowai_logo_text.svg      # Logo with text
assets/logos/flowai_logo_horizontal.svg # Horizontal layout
```

2. **Icon Variations:**
```
assets/logos/flowai_icon_light.svg     # Light theme
assets/logos/flowai_icon_dark.svg      # Dark theme
assets/logos/flowai_icon_monochrome.svg # Single color
```

### Generate PNG Assets
Create a script to generate all required sizes:

```bash
#!/bin/bash
# generate_all_icons.sh

SOURCE_SVG="assets/logos/flowai_icon.svg"
TEMP_DIR="temp_icons"

# Create temp directory
mkdir -p $TEMP_DIR

# iOS Icons
echo "🍎 Generating iOS icons..."
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset

# Generate all iOS sizes
declare -a iOS_SIZES=(
    "20:Icon-App-20x20@1x.png"
    "29:Icon-App-29x29@1x.png"
    "40:Icon-App-40x40@1x.png"
    "58:Icon-App-29x29@2x.png"
    "60:Icon-App-60x60@1x.png"
    "76:Icon-App-76x76@1x.png"
    "80:Icon-App-40x40@2x.png"
    "87:Icon-App-29x29@3x.png"
    "120:Icon-App-60x60@2x.png"
    "152:Icon-App-76x76@2x.png"
    "167:Icon-App-83.5x83.5@2x.png"
    "180:Icon-App-60x60@3x.png"
    "1024:Icon-App-1024x1024@1x.png"
)

for size_info in "${iOS_SIZES[@]}"; do
    IFS=':' read -r size filename <<< "$size_info"
    echo "  📱 $filename ($size px)"
    rsvg-convert -w $size -h $size "$SOURCE_SVG" -o "ios/Runner/Assets.xcassets/AppIcon.appiconset/$filename"
done

# Android Icons
echo "🤖 Generating Android icons..."
declare -a ANDROID_SIZES=(
    "48:mdpi"
    "72:hdpi" 
    "96:xhdpi"
    "144:xxhdpi"
    "192:xxxhdpi"
)

for size_info in "${ANDROID_SIZES[@]}"; do
    IFS=':' read -r size density <<< "$size_info"
    echo "  📱 $density ($size px)"
    
    # Create directories
    mkdir -p "android/app/src/main/res/mipmap-$density"
    
    # Generate icons
    rsvg-convert -w $size -h $size "$SOURCE_SVG" -o "android/app/src/main/res/mipmap-$density/ic_launcher.png"
    rsvg-convert -w $size -h $size "$SOURCE_SVG" -o "android/app/src/main/res/mipmap-$density/launcher_icon.png"
done

# macOS Icons
echo "🖥️ Generating macOS icons..."
mkdir -p macos/Runner/Assets.xcassets/AppIcon.appiconset

declare -a MACOS_SIZES=(
    "16:icon_16x16.png"
    "32:icon_16x16@2x.png"
    "32:icon_32x32.png"
    "64:icon_32x32@2x.png"
    "128:icon_128x128.png"
    "256:icon_128x128@2x.png"
    "256:icon_256x256.png"
    "512:icon_256x256@2x.png"
    "512:icon_512x512.png"
    "1024:icon_512x512@2x.png"
)

for size_info in "${MACOS_SIZES[@]}"; do
    IFS=':' read -r size filename <<< "$size_info"
    echo "  🖥️ $filename ($size px)"
    rsvg-convert -w $size -h $size "$SOURCE_SVG" -o "macos/Runner/Assets.xcassets/AppIcon.appiconset/$filename"
done

# Web Icons
echo "🌐 Generating web icons..."
mkdir -p web/icons

declare -a WEB_SIZES=(
    "16:Icon-16.png"
    "32:Icon-32.png"
    "192:Icon-192.png"
    "512:Icon-512.png"
)

for size_info in "${WEB_SIZES[@]}"; do
    IFS=':' read -r size filename <<< "$size_info"
    echo "  🌐 $filename ($size px)"
    rsvg-convert -w $size -h $size "$SOURCE_SVG" -o "web/icons/$filename"
done

# Generate favicon
echo "🌐 Generating favicon..."
rsvg-convert -w 32 -h 32 "$SOURCE_SVG" -o "web/favicon.png"
convert web/favicon.png web/favicon.ico

# Clean up
rm -rf $TEMP_DIR

echo "✅ All icons generated successfully!"
```

## 📝 Step 4: Update Configuration Files

### iOS Contents.json
Update `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`:

```json
{
  "images": [
    {
      "filename": "Icon-App-20x20@1x.png",
      "idiom": "iphone",
      "scale": "1x",
      "size": "20x20"
    },
    {
      "filename": "Icon-App-29x29@1x.png",
      "idiom": "iphone", 
      "scale": "1x",
      "size": "29x29"
    },
    {
      "filename": "Icon-App-40x40@1x.png",
      "idiom": "iphone",
      "scale": "1x", 
      "size": "40x40"
    },
    {
      "filename": "Icon-App-29x29@2x.png",
      "idiom": "iphone",
      "scale": "2x",
      "size": "29x29"
    },
    {
      "filename": "Icon-App-40x40@2x.png",
      "idiom": "iphone",
      "scale": "2x",
      "size": "40x40"
    },
    {
      "filename": "Icon-App-60x60@2x.png",
      "idiom": "iphone",
      "scale": "2x",
      "size": "60x60"
    },
    {
      "filename": "Icon-App-29x29@3x.png",
      "idiom": "iphone",
      "scale": "3x",
      "size": "29x29"
    },
    {
      "filename": "Icon-App-40x40@3x.png",
      "idiom": "iphone",
      "scale": "3x",
      "size": "40x40"
    },
    {
      "filename": "Icon-App-60x60@3x.png",
      "idiom": "iphone",
      "scale": "3x",
      "size": "60x60"
    },
    {
      "filename": "Icon-App-1024x1024@1x.png",
      "idiom": "ios-marketing",
      "scale": "1x",
      "size": "1024x1024"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
```

### macOS Contents.json
Update `macos/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`:

```json
{
  "images": [
    {
      "filename": "icon_16x16.png",
      "idiom": "mac",
      "scale": "1x",
      "size": "16x16"
    },
    {
      "filename": "icon_16x16@2x.png", 
      "idiom": "mac",
      "scale": "2x",
      "size": "16x16"
    },
    {
      "filename": "icon_32x32.png",
      "idiom": "mac", 
      "scale": "1x",
      "size": "32x32"
    },
    {
      "filename": "icon_32x32@2x.png",
      "idiom": "mac",
      "scale": "2x", 
      "size": "32x32"
    },
    {
      "filename": "icon_128x128.png",
      "idiom": "mac",
      "scale": "1x",
      "size": "128x128"
    },
    {
      "filename": "icon_128x128@2x.png",
      "idiom": "mac",
      "scale": "2x",
      "size": "128x128"
    },
    {
      "filename": "icon_256x256.png",
      "idiom": "mac",
      "scale": "1x",
      "size": "256x256"
    },
    {
      "filename": "icon_256x256@2x.png",
      "idiom": "mac",
      "scale": "2x",
      "size": "256x256"
    },
    {
      "filename": "icon_512x512.png",
      "idiom": "mac",
      "scale": "1x", 
      "size": "512x512"
    },
    {
      "filename": "icon_512x512@2x.png",
      "idiom": "mac",
      "scale": "2x",
      "size": "512x512"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
```

### Web Manifest
Update `web/manifest.json`:

```json
{
  "name": "Flow Ai",
  "short_name": "Flow Ai",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#2563EB",
  "theme_color": "#2563EB",
  "description": "AI-powered feminine health companion",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png", 
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

## 🎯 Step 5: Brand Assets Creation

### Create Additional Brand Assets
```
assets/branding/
├── logos/
│   ├── flowai_logo_primary.svg
│   ├── flowai_logo_secondary.svg
│   ├── flowai_logo_white.svg
│   └── flowai_wordmark.svg
├── icons/
│   ├── flowai_icon_primary.svg
│   ├── flowai_icon_secondary.svg
│   └── flowai_icon_white.svg
├── social/
│   ├── og_image.png (1200x630)
│   ├── twitter_card.png (1200x600)
│   └── linkedin_cover.png (1584x396)
└── marketing/
    ├── app_store_feature.png (1024x500)
    ├── play_store_feature.png (1024x500)
    └── web_hero.png (1920x1080)
```

### Create App Store Screenshots Template
```
assets/marketing/screenshots/
├── ios/
│   ├── iphone_6.7_inch/    # iPhone 14 Pro Max
│   ├── iphone_6.1_inch/    # iPhone 14 Pro
│   ├── iphone_5.5_inch/    # iPhone 8 Plus
│   └── ipad_12.9_inch/     # iPad Pro
├── android/
│   ├── phone/
│   ├── tablet_7_inch/
│   └── tablet_10_inch/
└── templates/
    ├── screenshot_template.sketch
    └── screenshot_template.figma
```

## 🚀 Step 6: Automation Setup

### Create Icon Generation Script
Save the icon generation script as executable:

```bash
# Make script executable
chmod +x generate_all_icons.sh

# Run script
./generate_all_icons.sh
```

### Add to Build Process
Update `pubspec.yaml` to include icon generation:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/logos/flowai_icon.svg"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "assets/logos/flowai_icon.svg"
  windows:
    generate: true
    image_path: "assets/logos/flowai_icon.svg"
  macos:
    generate: true
    image_path: "assets/logos/flowai_icon.svg"
```

Then run:
```bash
flutter packages pub get
flutter packages pub run flutter_launcher_icons:generate
```

## ✅ Step 7: Verification Checklist

### Icon Verification
- [ ] All iOS icon sizes generated correctly
- [ ] All Android icon sizes generated correctly  
- [ ] All macOS icon sizes generated correctly
- [ ] All web icons and favicon generated
- [ ] Contents.json files updated correctly
- [ ] Icons display properly in simulators/emulators
- [ ] Icons display properly on physical devices

### Brand Consistency
- [ ] Colors match brand guidelines
- [ ] Design is consistent across all sizes
- [ ] Icons are readable at smallest sizes
- [ ] Icons work on both light and dark backgrounds
- [ ] App Store/Play Store assets created

### Technical Validation
- [ ] SVG files are optimized and clean
- [ ] PNG files are properly compressed
- [ ] No transparency issues on required platforms
- [ ] Icons meet platform-specific guidelines
- [ ] Build process includes icon generation

## 🛠️ Tools and Resources

### Design Tools
- **Vector Graphics:** Figma, Sketch, Adobe Illustrator
- **Image Conversion:** rsvg-convert, ImageMagick, sharp-cli
- **Icon Generators:** flutter_launcher_icons, app-icon-generator

### Platform Guidelines
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Android Material Design Icons](https://material.io/design/iconography/)
- [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos/)

### Testing Tools
- iOS Simulator (Xcode)
- Android Emulator (Android Studio)
- Physical devices for final validation

---

**⚠️ Important Notes:**
- Always test icons on actual devices
- Keep source SVG files in version control
- Maintain consistent visual style across all platforms
- Follow platform-specific design guidelines
- Compress PNG files for optimal file sizes
