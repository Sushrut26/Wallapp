# Wallapp Setup Guide

This guide will help you set up and run the Wallapp on your fridge tablet.

## Hardware Requirements

- Android tablet (recommended 10" or larger)
- Tablet mount for refrigerator
- Power source near refrigerator or long USB cable
- (Optional) Local server for running LLM

## Quick Start

### 1. Install Flutter

**Windows:**
1. Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
2. Extract to `C:\src\flutter`
3. Add `C:\src\flutter\bin` to PATH
4. Run `flutter doctor` to verify installation

**macOS:**
```bash
brew install flutter
flutter doctor
```

**Linux:**
```bash
sudo snap install flutter --classic
flutter doctor
```

### 2. Set Up the Project

```bash
# Clone the repository
git clone <your-repo-url>
cd Wallapp

# Install dependencies
flutter pub get

# Verify everything is set up
flutter doctor -v
```

### 3. Connect Your Tablet

**Via USB:**
1. Enable Developer Options on your Android tablet:
   - Go to Settings > About Tablet
   - Tap "Build Number" 7 times
2. Enable USB Debugging:
   - Settings > Developer Options > USB Debugging
3. Connect tablet via USB
4. Verify connection: `flutter devices`

**Via WiFi (for development):**
1. Connect tablet via USB first
2. Run: `adb tcpip 5555`
3. Find tablet's IP address (Settings > About > Status)
4. Run: `adb connect <tablet-ip>:5555`
5. Disconnect USB cable

### 4. Run the App

```bash
# List available devices
flutter devices

# Run on your tablet
flutter run -d <device-id>

# Or for release mode
flutter run --release -d <device-id>
```

## Setting Up Local LLM (Recommended)

For the best AI meal planning experience:

### Option 1: Ollama (Easiest)

1. Install Ollama:
   - **Mac/Linux:** `curl https://ollama.ai/install.sh | sh`
   - **Windows:** Download from https://ollama.ai/download

2. Pull a model:
```bash
ollama pull llama2
# or for a smaller model:
ollama pull llama2:7b
```

3. Start Ollama:
```bash
ollama serve
```

4. Test it:
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "Suggest a vegetarian meal"
}'
```

### Option 2: Run LLM on Raspberry Pi

If you have a Raspberry Pi 4 (8GB RAM recommended):

1. Install Ollama on Pi:
```bash
curl https://ollama.ai/install.sh | sh
ollama pull llama2:7b
```

2. Find Pi's IP address:
```bash
hostname -I
```

3. Update `lib/services/llm_service.dart`:
```dart
LLMService({
  this.baseUrl = 'http://<raspberry-pi-ip>:11434',
  this.model = 'llama2:7b',
});
```

### Option 3: Use Fallback Suggestions

The app includes built-in vegetarian meal suggestions that work without any LLM setup. They'll activate automatically if no LLM is available.

## Building for Production

### Create Release APK

```bash
# Build APK
flutter build apk --release

# APK location:
# build/app/outputs/flutter-apk/app-release.apk
```

### Install on Tablet

**Via USB:**
```bash
flutter install -d <device-id>
```

**Manual Installation:**
1. Copy `app-release.apk` to tablet
2. Open file manager on tablet
3. Tap the APK file
4. Allow installation from unknown sources if prompted
5. Tap "Install"

## Tablet Configuration

### Recommended Settings

1. **Display Settings:**
   - Keep screen on while charging
   - Brightness: Auto or 50-70%
   - Screen timeout: Never (when charging)

2. **Battery Optimization:**
   - Settings > Battery > Battery Optimization
   - Find Wallapp and set to "Don't optimize"

3. **Auto-start:**
   - Install a launcher app that auto-starts on boot
   - Or use Tasker to launch Wallapp on boot

4. **Kiosk Mode (Optional):**
   For a dedicated tablet:
   - Install "Fully Kiosk Browser" or similar
   - Configure to launch Wallapp on startup
   - Lock screen to prevent accidental exits

### Network Setup

**WiFi:**
- Connect tablet to your home WiFi
- Settings > WiFi > Advanced > Keep WiFi on during sleep: Always

**For LLM Access:**
- Ensure tablet and LLM server are on same network
- Check firewall allows port 11434

## Calendar Sync Setup

To sync with your phone's calendar:

### Android:

1. Add permissions to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_CALENDAR" />
<uses-permission android:name="android.permission.WRITE_CALENDAR" />
```

2. The app will request permissions on first run

3. Events will sync with Google Calendar

### iOS (if building for iPad):

1. Add to `ios/Runner/Info.plist`:
```xml
<key>NSCalendarsUsageDescription</key>
<string>Access calendar to sync events</string>
```

## Troubleshooting

### App Won't Install
- Enable "Install from Unknown Sources" in tablet settings
- Try: `adb uninstall com.wallapp.wallapp` then reinstall

### LLM Connection Failed
- Check LLM server is running: `curl http://localhost:11434`
- Verify IP address in `llm_service.dart`
- Check firewall settings
- App will use fallback suggestions if LLM unavailable

### Data Lost After Restart
- Check app permissions (Storage)
- Verify SharedPreferences working: `adb logcat | grep SharedPreferences`

### Screen Stays Black
- Tablet may be in sleep mode
- Enable "Stay awake" in Developer Options
- Ensure power saving mode is off

### Touch Not Working
- Clean screen
- Calibrate touchscreen in Settings
- Check if screen protector is interfering

## Optimization Tips

### Performance
1. Close background apps
2. Disable animations: Developer Options > Window/Transition animation scale > Off
3. Use release build, not debug build

### Battery Life
1. Lower screen brightness
2. Use dark mode (future feature)
3. Ensure tablet is plugged in

### Storage
- App uses minimal storage (~50MB)
- Data stored in SharedPreferences (< 1MB typically)
- Clear cache if needed: Settings > Apps > Wallapp > Clear Cache

## Updating the App

```bash
# Pull latest code
git pull origin main

# Get dependencies
flutter pub get

# Build and install
flutter build apk --release
flutter install -d <device-id>
```

## Customization

See README.md for customization options including:
- Adding family members
- Changing LLM endpoint
- Customizing meal categories
- Theming

## Support

If you encounter issues:
1. Check `flutter doctor -v`
2. Review logs: `adb logcat | grep flutter`
3. Open an issue on GitHub

## Next Steps

After setup:
1. Add your family members' to-do lists
2. Plan meals for the week
3. Add important calendar events
4. Enjoy your organized fridge assistant!
