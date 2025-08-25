#!/bin/bash

# K53 App Test Runner
# Run this script to execute all tests in the project

echo "🚀 Starting K53 App Test Suite..."
echo "=================================="

# Function to run tests with pretty output
run_test() {
    local test_file=$1
    local test_name=$2
    
    echo ""
    echo "🧪 Running $test_name..."
    echo "----------------------------------"
    
    if flutter test "$test_file"; then
        echo "✅ $test_name - PASSED"
        return 0
    else
        echo "❌ $test_name - FAILED"
        return 1
    fi
}

# Run individual test files
run_test "test/unit/core/utils/accessibility_utils_test.dart" "Accessibility Utils Unit Tests"
ACCESSIBILITY_UTILS_RESULT=$?

run_test "test/unit/core/utils/performance_utils_test.dart" "Performance Utils Unit Tests"
PERFORMANCE_UTILS_RESULT=$?

run_test "test/widget/accessibility_test_screen_test.dart" "Accessibility Test Screen Widget Tests"
ACCESSIBILITY_SCREEN_RESULT=$?

run_test "test/widget_test.dart" "Basic Widget Tests"
BASIC_WIDGET_RESULT=$?

# Summary
echo ""
echo "=================================="
echo "📊 Test Suite Summary:"
echo "----------------------------------"

if [ $ACCESSIBILITY_UTILS_RESULT -eq 0 ]; then
    echo "✅ Accessibility Utils - PASSED"
else
    echo "❌ Accessibility Utils - FAILED"
fi

if [ $PERFORMANCE_UTILS_RESULT -eq 0 ]; then
    echo "✅ Performance Utils - PASSED"
else
    echo "❌ Performance Utils - FAILED"
fi

if [ $ACCESSIBILITY_SCREEN_RESULT -eq 0 ]; then
    echo "✅ Accessibility Test Screen - PASSED"
else
    echo "❌ Accessibility Test Screen - FAILED"
fi

if [ $BASIC_WIDGET_RESULT -eq 0 ]; then
    echo "✅ Basic Widget Tests - PASSED"
else
    echo "❌ Basic Widget Tests - FAILED"
fi

# Overall result
TOTAL_FAILURES=$((ACCESSIBILITY_UTILS_RESULT + PERFORMANCE_UTILS_RESULT + ACCESSIBILITY_SCREEN_RESULT + BASIC_WIDGET_RESULT))

if [ $TOTAL_FAILURES -eq 0 ]; then
    echo ""
    echo "🎉 All tests passed!"
    echo "✨ Test suite completed successfully!"
    exit 0
else
    echo ""
    echo "💥 $TOTAL_FAILURES test suite(s) failed!"
    echo "⚠️  Please check the test output above for details."
    exit 1
fi