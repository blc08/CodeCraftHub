#!/bin/bash

# ============================================================================
# CodeCraftHub API - Test Script
# ============================================================================
# This script contains all test cases for the CodeCraftHub API
#
# Prerequisites:
#   1. Make sure your Flask app is running: python app.py
#   2. The app should be running on http://localhost:5000
#
# Usage Options:
#   Option 1: Run individual commands by copying and pasting
#   Option 2: Run entire script: chmod +x test_api.sh && ./test_api.sh
#
# Tips for beginners:
#   - Each curl command is independent, run them one at a time
#   - Read the expected response before running each command
#   - The -s flag means "silent" (hides progress bar)
#   - The | json_pp part formats JSON output (optional, remove if not installed)
# ============================================================================

echo "=============================================="
echo "   CodeCraftHub API Test Suite"
echo "=============================================="
echo ""
echo "Make sure your Flask app is running on http://localhost:5000"
echo "Press Enter to start testing..."
read

# ============================================================================
# SECTION 1: SUCCESSFUL OPERATIONS
# ============================================================================

echo ""
echo "=============================================="
echo "SECTION 1: TESTING SUCCESSFUL OPERATIONS"
echo "=============================================="

# ----------------------------------------------------------------------------
# TEST 1.1: Create First Course (POST)
# ----------------------------------------------------------------------------
echo ""
echo ">>> TEST 1.1: Create First Course"
echo "Command:"
echo 'curl -s -X POST http://localhost:5000/api/courses \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Python Basics\",
    \"description\": \"Learn Python fundamentals including variables, loops, and functions\",
    \"target_date\": \"2025-03-15\",
    \"status\": \"Not Started\"
  }"'
echo ""
echo "Expected Response (Status: 201 Created):"
echo '{
    "message": "Course created successfully",
    "course": {
        "id": 1,
        "name": "Python Basics",
        "description": "Learn Python fundamentals including variables, loops, and functions",
        "target_date": "2025-03-15",
        "status": "Not Started",
        "created_at": "2025-01-13T10:30:00"
    }
}'
echo ""
echo "Running test..."
curl -s -X POST http://localhost:5000/api/courses \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Python Basics",
    "description": "Learn Python fundamentals including variables, loops, and functions",
    "target_date": "2025-03-15",
    "status": "Not Started"
  }'
echo ""
echo ""
echo "Press Enter to continue..."
read

# ----------------------------------------------------------------------------
# TEST 1.2: Create Second Course (POST)
# ----------------------------------------------------------------------------
echo ""
echo ">>> TEST 1.2: Create Second Course"
echo "Command:"
echo 'curl -s -X POST http://localhost:5000/api/courses \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Flask Web Development\",
    \"description\": \"Build REST APIs with Flask framework\",
    \"target_date\": \"2025-04-01\",
    \"status\": \"In Progress\"
  }"'
echo ""
echo "Expected Response (Status: 201 Created):"
echo '{
    "message": "Course created successfully",
    "course": {
        "id": 2,
        "name": "Flask Web Development",
        "description": "Build REST APIs with Flask framework",
        "target_date": "2025-04-01",
        "status": "In Progress",
        "created_at": "2025-01-13T10:31:00"
    }
}'
echo ""
echo "Running test..."
curl -s -X POST http://localhost:5000/api/