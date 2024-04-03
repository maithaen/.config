#!/bin/bash

packages=("neovim" "git" "zsh" "oh-my-zsh" "curl" "wget" "python3" "python3-pip" "python3-venv" "gcc" "g++" "make" "cmake" "neofetch" "adb" "fastboot")

is_installed() {
  dpkg -s $1 >/dev/null 2>&1
}

install() {
  if ! is_installed $1; then
    echo "$1 is not installed. Installing..."
    sudo apt install -y $1
    echo "$1 has been installed."
  else
    echo "$1 is already installed."
  fi
}

install_vscode() {
  if ! [ -x "$(command -v code)" ]; then
    echo "Visual Studio Code is not installed. Installing..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo rm packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt update
    sudo apt install -y code
    echo "Visual Studio Code has been installed."
  else
    echo "Visual Studio Code is already installed."
  fi
}

# Main
echo "Welcome to the Python on Termux installer."
read -p "Please choose one of the following options:
1. Install all packages
2. Install packages from list
3. Install Visual Studio Code
4. Exit
Enter your choice: " choice

case $choice in
  1)
    echo "Installing all packages..."
    sudo apt update
    sudo apt upgrade -y
    for package in "${packages[@]}"; do
      install "$package"
    done
    echo "All packages have been installed."
    install_vscode
    ;;
  2)
    echo "Packages List:"
    for package in "${packages[@]}"; do
      echo "$package"
    done
    for package in "${packages[@]}"; do
      install "$package"
    done
    ;;
  3)
    install_vscode
    ;;
  4)
    exit
    ;;
  *)
    echo "Invalid choice. Please choose a valid option."
    ;;
esac
