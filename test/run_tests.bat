@echo off
echo.
echo 🚀 Starting K53 App Test Suite...
echo ==================================

setlocal enabledelayedexpansion

set /a TOTAL_FAILURES=0
set /a TEST_COUNT=0

:run_test
set TEST_FILE=%~1
set TEST_NAME=%~2
if "!TEST_FILE!"=="" goto :summary

echo.
echo 🧪 Running !TEST_NAME!...
echo -----------------------------------

flutter test "!TEST_FILE!"
if !errorlevel! equ 0 (
    echo ✅ !TEST_NAME! - PASSED
) else (
    echo ❌ !TEST_NAME! - FAILED
    set /a TOTAL_FAILURES+=1
)

set /a TEST_COUNT+=1
shift
shift
goto :run_test

:summary
echo.
echo ==================================
echo 📊 Test Suite Summary:
echo ----------------------------------

if !TOTAL_FAILURES! equ 0 (
    echo.
    echo 🎉 All tests passed!
    echo ✨ Test suite completed successfully!
    exit /b 0
) else (
    echo.
    echo 💥 !TOTAL_FAILURES! test suite(s) failed!
    echo ⚠️  Please check the test output above for details.
    exit /b 1
)

:: Test files to run
call :run_test "test/unit/core/utils/accessibility_utils_test.dart" "Accessibility Utils Unit Tests"
call :run_test "test/unit/core/utils/performance_utils_test.dart" "Performance Utils Unit Tests"
call :run_test "test/widget/accessibility_test_screen_test.dart" "Accessibility Test Screen Widget Tests"
call :run_test "test/widget_test.dart" "Basic Widget Tests"

goto :summary