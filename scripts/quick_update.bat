@echo off
echo ========================================
echo    POS Felix - Quick Testing Update
echo ========================================
echo.

echo Current version: 0.9.0+1 (Testing)
echo.

echo [1/5] Removing old build...
if exist "build" rmdir /s /q build

echo [2/5] Cleaning and getting dependencies...
call flutter clean && call flutter pub get

echo [3/5] Generating code...
call dart run build_runner build --delete-conflicting-outputs

echo [4/5] Building fresh release APK...
call flutter build apk --release

echo [5/5] Installing fresh build to device...
call adb uninstall com.example.posfelix
call adb install build\app\outputs\flutter-apk\app-release.apk

echo.
echo ========================================
echo      FRESH TESTING BUILD READY!
echo ========================================
echo.
echo ✅ Fresh APK: build\app\outputs\flutter-apk\app-release.apk
echo ✅ Installed to device
echo 🧪 Version: 0.9.0+1 (Testing with syncing fixes)
echo.
pause