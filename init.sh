#!/bin/bash

set -e

REPO_URL="https://github.com/RobinArzB/config_dev.git"
CLONE_DIR="$HOME/git/"

# Ensure the script is run with sudo or as root for installing packages
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "git is not installed. Installing git..."
    apt-get update
    apt-get install -y git
fi

# Clone the repository
if [ ! -d "$CLONE_DIR" ]; then
    echo "Cloning the repository from $REPO_URL to $CLONE_DIR..."
    git clone $REPO_URL $CLONE_DIR
else
    echo "Repository already cloned."
fi

# Change to the cloned directory
cd $CLONE_DIR

# Ensure make is installed
echo "Updating package lists and installing make..."
apt-get update
apt-get install -y build-essential

# Run the Makefile
echo "Running Makefile..."
make all
