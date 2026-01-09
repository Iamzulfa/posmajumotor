@echo off
echo ========================================
echo    POS Felix - Fresh Testing Build
echo ========================================
echo.

echo Version: 0.9.0+1 (Testing Build)
echo.

echo [1/6] Removing old builds...
if exist "build" (
    echo Deleting build folder...
    rmdir /s /q build
)

echo [2/6] Flutter clean...
call flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed
    pause
    exit /b 1
)

echo [3/6] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed
    pause
    exit /b 1
)

echo [4/6] Generating code...
call dart run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo ERROR: Code generation failed
    pause
    exit /b 1
)

echo [5/6] Building fresh release APK...
call flutter build apk --release
if %errorlevel% neq 0 (
    echo ERROR: Release build failed
    pause
    exit /b 1
)

echo [6/6] Uninstalling old app and installing fresh...
echo Uninstalling old version...
call adb uninstall com.example.posfelix
echo Installing fresh build...
call adb install build\app\outputs\flutter-apk\app-release.apk

echo.
echo ========================================
echo       FRESH BUILD COMPLETE!
echo ========================================
echo.
echo ✅ Old builds deleted
echo ✅ Fresh APK built: build\app\outputs\flutter-apk\app-release.apk
echo ✅ Installed to device
echo.
echo Version: 0.9.0+1 (Testing)
echo Build Date: %date% %time%
echo.
echo 🧪 This is a TESTING build with syncing fixes
echo 📱 Ready for testing on multiple devices
echo.
pause