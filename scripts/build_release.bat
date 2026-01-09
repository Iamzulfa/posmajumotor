@echo off
echo ========================================
echo    POS Felix - Release Build Script
echo ========================================
echo.

echo [1/6] Cleaning previous builds...
call flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed
    pause
    exit /b 1
)

echo [2/6] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed
    pause
    exit /b 1
)

echo [3/6] Generating code...
call dart run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo ERROR: Code generation failed
    pause
    exit /b 1
)

echo [4/6] Running tests (optional)...
REM call flutter test
REM if %errorlevel% neq 0 (
REM     echo WARNING: Tests failed, but continuing...
REM )

echo [5/6] Building release APK...
call flutter build apk --release
if %errorlevel% neq 0 (
    echo ERROR: Release build failed
    pause
    exit /b 1
)

echo [6/6] Building app bundle (for Play Store)...
call flutter build appbundle --release
if %errorlevel% neq 0 (
    echo ERROR: App bundle build failed
    pause
    exit /b 1
)

echo.
echo ========================================
echo           BUILD SUCCESSFUL!
echo ========================================
echo.
echo APK Location: build\app\outputs\flutter-apk\app-release.apk
echo Bundle Location: build\app\outputs\bundle\release\app-release.aab
echo.
echo Version: 1.0.1+2
echo Build Date: %date% %time%
echo.
pause