#!/bin/bash

# Declare functions upfront
is_package_installed() {
  dpkg -l "$1" &> /dev/null
  return $?
}

install_package() {
  if ! is_package_installed "$1"; then
    echo "$1 is not installed. Installing..."
    sudo apt update
    sudo apt install "$1" -y
    echo "$1 has been installed."
  else
    echo "$1 is already installed."
  fi
}

install_vscode() {
  if ! command -v code &> /dev/null; then
    echo "Visual Studio Code is not installed. Installing..."
    # Install VS Code
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    rm packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt update
    sudo apt install code -y 
    echo "Visual Studio Code has been installed."
  else
    echo "Visual Studio Code is already installed."
  fi
}

# Read-only array of packages
packages=(
  "neovim" "git" "zsh"
  "oh-my-zsh" "curl" "wget" "python3" 
  "python3-pip" "python3-venv" "gcc" "g++"
  "make" "cmake" "neofetch"
  "adb" "fastboot"
)

# Main script

echo "Please choose one of the following options:"
echo "1. Install all packages"
echo "2. Install only the packages listed above" 
echo "3. Install Visual Studio Code"
echo "4. Exit"

read -p "Enter your choice: " choice

if [ "$choice" -eq 1 ]; then
  # Update apt
  echo "Updating apt..."
  sudo apt update && sudo apt upgrade -y
  # Install all packages
  echo "Installing all packages..."
  
  for package in "${packages[@]}"; do
    install_package "$package"
  done
  
  echo "All packages have been installed."
  install_vscode

elif [ "$choice" -eq 2 ]; then
  # Install packages from list  
  for package in "${packages[@]}"; do
    install_package "$package"
  done

elif [ "$choice" -eq 3 ]; then
  # Install VS Code
  install_vscode

elif [ "$choice" -eq 4 ]; then
  # Exit program
  exit 0
fi