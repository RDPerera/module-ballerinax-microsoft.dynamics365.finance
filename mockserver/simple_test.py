#!/usr/bin/env python3
"""
Simple test to verify the mock server works
"""

from flask import Flask, jsonify
import sys
import os

# Add the current directory to the path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Simple test server
app = Flask(__name__)

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "message": "Mock server is working!"})

@app.route('/test')
def test():
    return jsonify({"message": "Test endpoint working", "version": "1.0.0"})

if __name__ == '__main__':
    print("Starting simple test server...")
    print("Available at: http://localhost:8081")
    app.run(debug=True, host='0.0.0.0', port=8081)
