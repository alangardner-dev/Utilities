#!/user/bin/env bash

# Create a virtual environment
python3 -m venv venv

# Activate the virtual environment
# On macOS/Linux:
source venv/bin/activate

# Find a requirements file
REQUIREMENTS_FILE=$(ls *.txt 2>/dev/null | grep -i requirements | head -n 1)

if [ -n "$REQUIREMENTS_FILE" ]; then
    echo "Using requirements file: $REQUIREMENTS_FILE"
    pip install -r "$REQUIREMENTS_FILE"
else
    echo "No requirements file found. Skipping pip install."
fi
