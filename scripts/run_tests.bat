@echo off
REM Script untuk menjalankan unit tests
REM Usage: run_tests.bat [option]
REM Options: all, security, coverage

echo ========================================
echo POS Felix - Unit Test Runner
echo ========================================
echo.

if "%1"=="coverage" goto coverage
if "%1"=="security" goto security
if "%1"=="all" goto all
goto help

:all
echo Running all tests...
flutter test
goto end

:security
echo Running security tests only...
flutter test test/config/constants/supabase_config_test.dart
flutter test test/core/services/secure_storage_service_test.dart
flutter test test/core/services/offline_service_test.dart
goto end

:coverage
echo Running tests with coverage...
flutter test --coverage
echo.
echo Coverage report generated at: coverage/lcov.info
echo To view HTML report, run: genhtml coverage/lcov.info -o coverage/html
goto end

:help
echo Usage: run_tests.bat [option]
echo.
echo Options:
echo   all       - Run all tests (default)
echo   security  - Run security tests only
echo   coverage  - Run tests with coverage report
echo.
echo Examples:
echo   run_tests.bat
echo   run_tests.bat security
echo   run_tests.bat coverage
goto end

:end
echo.
echo ========================================
echo Test run completed!
echo ========================================
