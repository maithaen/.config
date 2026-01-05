# PyCLI

This directory contains Python scripts and utilities for CLI (Command Line Interface) development. These tools are designed to streamline development workflows and provide useful automation capabilities.

## Files

- **devinit.py**: A script to initialize development environments, including setting up virtual environments and installing dependencies.

- **devutils.py**: Contains utility functions to assist with common development tasks.

- **orun.py**: A script for running commands and streaming output with enhanced formatting.

- **requirements.txt**: Lists the Python dependencies required for the scripts in this directory. Use this file to install dependencies with `pip`.

- **setup_pycli.py**: A setup script to configure the PyCLI environment.

## Getting Started

1. **Set Up Python Environment**:
   - Ensure you have Python installed on your system.
   - Create a virtual environment:
     ```bash
     python -m venv venv
     ```
   - Activate the virtual environment:
     - On Windows: `venv\Scripts\activate`
     - On macOS/Linux: `source venv/bin/activate`

2. **Install Dependencies**:
   - Use `pip` to install the required dependencies:
     ```bash
     pip install -r requirements.txt
     ```

3. **Run Scripts**:
   - Use the provided Python scripts for their respective purposes. For example:
     ```bash
     python devinit.py
     ```

4. **Customize**:
   - Modify the scripts as needed to suit your development workflow.

## Tips for New Users

- **Virtual Environments**:
  - Always use a virtual environment to isolate dependencies for your project.

- **Explore the Scripts**:
  - Read through the scripts to understand their functionality and how they can be adapted to your needs.

- **Keep Dependencies Updated**:
  - Regularly update the `requirements.txt` file to reflect the dependencies used in your project.

For more information, refer to the comments within each script or consult the Python documentation.