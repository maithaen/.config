import os
import subprocess

packages = [
  "neovim", "git", "zsh",
  "oh-my-zsh", "curl", "wget", "python3",
  "python3-pip", "python3-venv", "gcc", "g++",
  "make", "cmake", "neofetch",
  "adb", "fastboot"
]

def is_installed(package):
  return subprocess.call(['dpkg', '-s', package]) == 0

def install(package):
  if not is_installed(package):
    print(f'{package} is not installed. Installing...')
    subprocess.run(['sudo', 'apt', 'install', '-y', package])
    print(f'{package} has been installed.')
  else:
    print(f'{package} is already installed.')

def install_vscode():
  if not os.path.exists('/usr/bin/code'):
    print('Visual Studio Code is not installed. Installing...')
    subprocess.run(['wget', '-qO-', 'https://packages.microsoft.com/keys/microsoft.asc', '|', 'gpg', '--dearmor', '>', 'packages.microsoft.gpg'])
    subprocess.run(['sudo', 'install', '-o', 'root', '-g', 'root', '-m', '644', 'packages.microsoft.gpg', '/etc/apt/trusted.gpg.d/'])
    subprocess.run(['rm', 'packages.microsoft.gpg']) 
    subprocess.run(['sudo', 'sh', '-c', 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'])
    subprocess.run(['sudo', 'apt', 'update']) 
    subprocess.run(['sudo', 'apt', 'install', '-y', 'code'])
    print('Visual Studio Code has been installed.')
  else:
    print('Visual Studio Code is already installed.')

# Mian
if __name__ == '__main__':
  print('Welcome to the Python on Termux installer.')
  choice = int(input("Please choose one of the following options:\n"
                    "1. Install all packages\n"
                    "2. Install packages from list\n"
                    "3. Install Visual Studio Code\n"
                    "4. Exit\n"
                    "Enter your choice: "))

  if choice == 1:
    print('Installing all packages...')
    subprocess.run(['sudo', 'apt', 'update'])
    subprocess.run(['sudo', 'apt', 'upgrade', '-y'])
    for package in packages:
      install(package)
    print('All packages have been installed.')
    install_vscode()

  elif choice == 2:
    print('Packages List:')
    for package in packages:
      print(package)
    for package in packages:
      install(package)

  elif choice == 3:
    install_vscode()

  elif choice == 4:
    exit()
