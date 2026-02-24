# FlowSense - iPhone 16 Plus Configuration

This project is configured to always run on **iPhone 16 Plus** simulator by default.

## 🚀 Quick Start

### Option 1: Simple Run Script
```bash
./run.sh
```

### Option 2: Detailed Run Script
```bash
./run_iphone16plus.sh
```

### Option 3: Direct Flutter Command
```bash
flutter run --debug -d "4AE9785A-6AA6-47F4-8DB1-6C6F84DA1B09"
```

## 📱 Device Information

- **Device**: iPhone 16 Plus
- **Device ID**: `4AE9785A-6AA6-47F4-8DB1-6C6F84DA1B09`
- **Platform**: iOS Simulator
- **Runtime**: iOS 18.5

## 🛠️ Configuration Files

### VS Code Launch Configuration
- **File**: `.vscode/launch.json`
- **Usage**: Use F5 or "Run and Debug" in VS Code

### Flutter Device File
- **File**: `.flutter-device`
- **Usage**: Stores the default device ID for Flutter tools

### Shell Scripts
- **`run.sh`**: Simple, quick runner
- **`run_iphone16plus.sh`**: Detailed runner with device checks and colorful output

## 🔧 Available Run Modes

1. **Debug Mode** (default)
   ```bash
   ./run.sh
   ```

2. **Profile Mode**
   ```bash
   ./run.sh --profile
   ```

3. **Release Mode**
   ```bash
   ./run.sh --release
   ```

4. **Hot Reload Mode**
   ```bash
   ./run.sh --hot
   ```

## 📋 Prerequisites

1. **Xcode** installed with iOS 18.5 Simulator
2. **Flutter SDK** properly configured
3. **iPhone 16 Plus** simulator available in Xcode

## 🆘 Troubleshooting

If the iPhone 16 Plus simulator is not available:

1. **Open Xcode**
2. **Go to**: Window → Devices and Simulators
3. **Click**: + (Add simulator)
4. **Choose**: iPhone 16 Plus with iOS 18.5
5. **Verify**: Run `flutter devices` to confirm availability

## 🎯 Features Verified

✅ App launches successfully on iPhone 16 Plus  
✅ All authentication flows working  
✅ Onboarding completion without errors  
✅ Updated splash screen text (no more "Futuristic")  
✅ Username capture and display working  
✅ All services initialized properly  

---

**Happy coding!** 🚀📱
