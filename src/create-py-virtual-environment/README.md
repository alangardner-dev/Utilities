# Create Python Virtual Environment

## Description

This script creates a Python virtual environment in the current directory, activates it, and optionally installs dependencies from a requirements file if one is found.

**Language**: Bash

**Dependencies**: Python 3

### Usage:

No arguments required. The script will:

1. Create a virtual environment named `venv` in the current directory
2. Activate the virtual environment
3. Look for a requirements file (any `.txt` file containing "requirements" in the name)
4. Install dependencies from the requirements file if found

**Example**

```bash
$ ./install-virtual-environment.sh

Using requirements file: requirements.txt
Collecting requests==2.31.0
  Downloading requests-2.31.0-py3-none-any.whl (62 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 62.6/62.6 kB 1.2 MB/s eta 0:00:00
Installing collected packages: requests
Successfully installed requests-2.31.0
```

**Note**: The virtual environment will be activated in the current shell session. To deactivate it later, simply run `deactivate`. 