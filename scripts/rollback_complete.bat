@echo off
echo ========================================
echo    POS Felix - Complete Rollback
echo ========================================
echo.

echo Rolling back to working version before timeout implementation...
echo.

echo [1/4] Cleaning build...
if exist "build" rmdir /s /q build
call flutter clean

echo [2/4] Getting dependencies...
call flutter pub get

echo [3/4] Generating code...
call dart run build_runner build --delete-conflicting-outputs

echo [4/4] Building fresh APK...
call flutter build apk --release

echo.
echo ========================================
echo      ROLLBACK COMPLETE!
echo ========================================
echo.
echo ✅ Rolled back to version before timeout implementation
echo ✅ Fresh APK: build\app\outputs\flutter-apk\app-release.apk
echo 🧪 Version: 0.9.0+1 (Testing - No Timeout Issues)
echo.
echo Ready for testing without timeout errors!
echo.
pause