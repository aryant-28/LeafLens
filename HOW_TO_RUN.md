# How to Run LeafLens

This guide explains how to run the LeafLens app on different platforms.

## Running on Web Browser (Easiest Option)

1. Make sure Flutter is installed and set up correctly:
   ```
   flutter doctor
   ```

2. Enable web support if not already enabled:
   ```
   flutter config --enable-web
   ```

3. Run the app in Edge browser (recommended):
   ```
   flutter run -d edge
   ```

   - Note: The TensorFlow model (plant diagnosis) functionality will be simulated in web mode with random results because TensorFlow Lite is not supported on web platforms.

## Running on Android

1. Connect an Android device via USB with developer options and USB debugging enabled

2. Run:
   ```
   flutter run -d android
   ```

## Running on Windows

1. Install Visual Studio 2022 with C++ workload:
   - Download from: https://visualstudio.microsoft.com/downloads/
   - Select only the "Desktop development with C++" workload
   - Make sure Windows 10/11 SDK is selected

2. Enable Windows desktop support:
   ```
   flutter config --enable-windows-desktop
   ```

3. Run on Windows:
   ```
   flutter run -d windows
   ```

## Running on iOS (requires macOS)

1. On a Mac with Xcode installed, run:
   ```
   flutter run -d ios
   ```

## Troubleshooting

### Web Issues
- If Edge is not found, try using Chrome:
  ```
  flutter run -d chrome
  ```
- If neither works, set the environment variable:
  ```
  set CHROME_EXECUTABLE=C:\path\to\chrome.exe
  flutter run -d web
  ```

### Android Issues
- Accept Android licenses:
  ```
  flutter doctor --android-licenses
  ```
- Install Android SDK tools:
  ```
  sdkmanager --install "cmdline-tools;latest"
  ```

### Windows Issues
- Make sure Developer Mode is enabled in Windows Settings
- Verify Visual Studio installation with C++ workload 