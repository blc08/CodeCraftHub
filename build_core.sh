#!/bin/bash
# ============================================================================
# CodeCraftHub - Project Setup Script
# ============================================================================
echo "🚀 Setting up CodeCraftHub project..."

# Create project directory structure
mkdir -p codecrafthub/data
cd codecrafthub || exit

# ============================================================================
# Create requirements.txt
# ============================================================================
echo "📦 Creating requirements.txt..."
cat << 'EOF' > requirements.txt
# CodeCraftHub Dependencies
# Install with: pip install -r requirements.txt
Flask==3.0.0
EOF

# ============================================================================
# Create initial courses.json data file
# ============================================================================
echo "📄 Creating initial data file..."
cat << 'EOF' > data/courses.json
{
    "courses": [],
    "next_id": 1
}
EOF

# ============================================================================
# Create the main Flask application (app.py)
# ============================================================================
echo "🐍 Creating app.py..."
cat << 'EOF' > app.py
"""
CodeCraftHub - A Simple Learning Platform API
=============================================
This Flask application provides a REST API to manage learning courses.
Data is stored in a JSON file (no database needed).
"""

from flask import Flask, request, jsonify
import json
import os
from datetime import datetime

app = Flask(__name__)

DATA_FILE = 'data/courses.json'
VALID_STATUSES = ('Not Started', 'In Progress', 'Completed')


# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def load_data():
    """Load course data from the JSON file."""
    try:
        if not os.path.exists(DATA_FILE):
            initial_data = {
                "courses": [],
                "next_id": 1
            }
            save_data(initial_data)
            return initial_data

        with open(DATA_FILE, 'r', encoding='utf-8') as file:
            return json.load(file)

    except json.JSONDecodeError as e:
        print(f"Error: JSON file is corrupted - {e}")
        raise Exception("Data file is corrupted. Please check courses.json")
    except PermissionError:
        print("Error: Permission denied when reading data file")
        raise Exception("Cannot read data file. Check file permissions.")


def save_data(data):
    """Save course data to the JSON file."""
    try:
        directory = os.path.dirname(DATA_FILE)
        if directory:
            os.makedirs(directory, exist_ok=True)

        with open(DATA_FILE, 'w', encoding='utf-8') as file:
            json.dump(data, file, indent=4, ensure_ascii=False)

    except PermissionError:
        print("Error: Permission denied when writing to data file")
        raise Exception("Cannot write to data file. Check file permissions.")


def validate_course_data(data, partial=False):
    """Validate incoming course payload."""
    if not isinstance(data, dict):
        return False, "Invalid JSON payload."

    required_fields = ['name', 'description', 'target_date', 'status']
    if not partial:
        for field in required_fields:
            if field not in data or not str(data[field]).strip():
                return False, f"Missing or empty required field: '{field}'"

    if 'status' in data and data['status'] not in VALID_STATUSES:
        return False, f"Invalid status. Must be one of: {', '.join(VALID_STATUSES)}"

    if 'target_date' in data:
        try:
            datetime.strptime(data['target_date'], '%Y-%m-%d')
        except ValueError:
            return False, "Invalid target_date format. Use YYYY-MM-DD."

    return True, None


# ============================================================================
# REST API ENDPOINTS
# ============================================================================

@app.route('/api/courses', methods=['GET'])
def get_courses():
    """Retrieve all courses (supports optional ?status= filter)."""
    data = load_data()
    courses = data.get('courses', [])
    status_filter = request.args.get('status')

    if status_filter:
        courses = [c for c in courses if c.get('status') == status_filter]

    return jsonify(courses), 200


@app.route('/api/courses/<int:course_id>', methods=['GET'])
def get_course(course_id):
    """Retrieve a single course by its ID."""
    data = load_data()
    course = next((c for c in data['courses'] if c['id'] == course_id), None)

    if not course:
        return jsonify({"error": f"Course with ID {course_id} not found"}), 404

    return jsonify(course), 200


@app.route('/api/courses', methods=['POST'])
def create_course():
    """Create a new course."""
    payload = request.get_json(silent=True)
    is_valid, error_msg = validate_course_data(payload)

    if not is_valid:
        return jsonify({"error": error_msg}), 400

    data = load_data()
    new_course = {
        "id": data['next_id'],
        "name": payload['name'].strip(),
        "description": payload['description'].strip(),
        "target_date": payload['target_date'],
        "status": payload['status'],
        "created_at": datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    }

    data['courses'].append(new_course)
    data['next_id'] += 1
    save_data(data)

    return jsonify(new_course), 201


@app.route('/api/courses/<int:course_id>', methods=['PUT'])
def update_course(course_id):
    """Update an existing course."""
    payload = request.get_json(silent=True)
    is_valid, error_msg = validate_course_data(payload, partial=True)

    if not is_valid:
        return jsonify({"error": error_msg}), 400

    data = load_data()
    course = next((c for c in data['courses'] if c['id'] == course_id), None)

    if not course:
        return jsonify({"error": f"Course with ID {course_id} not found"}), 404

    for field in ['name', 'description', 'target_date', 'status']:
        if field in payload:
            course[field] = payload[field].strip() if isinstance(payload[field], str) else payload[field]

    save_data(data)
    return jsonify(course), 200


@app.route('/api/courses/<int:course_id>', methods=['DELETE'])
def delete_course(course_id):
    """Delete a course by ID."""
    data = load_data()
    course = next((c for c in data['courses'] if c['id'] == course_id), None)

    if not course:
        return jsonify({"error": f"Course with ID {course_id} not found"}), 404

    data['courses'] = [c for c in data['courses'] if c['id'] != course_id]
    save_data(data)

    return jsonify({"message": f"Course {course_id} deleted successfully"}), 200


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
EOF

echo "✅ Project setup complete! Run 'cd codecrafthub && pip install -r requirements.txt && python3 app.py' to start."