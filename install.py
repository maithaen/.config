import subprocess
import os

def _get_package_list(distro):
  """
  Returns the package list based on the selected distro.
  """
  package_lists = {
      "ubuntu": [
          "python3",
          "python3-pip",
          "eza",
          "git",
          "curl",
          "wget",
          "neovim",
          "tmux",
          "alacritty",
          "neofetch",
          "htop",
          "zsh",
      ],
      "arch": [
          "python",
          "python-pip",
          "eza",
          "git",
          "curl",
          "wget",
          "neovim",
          "tmux",
          "alacritty",
          "neofetch",
          "htop",
          "zsh",
      ],
      "fedora": [
          "python3",
          "python3-pip",
          "eza",
          "git",
          "curl",
          "wget",
          "neovim",
          "tmux",
          "alacritty",
          "neofetch",
          "htop",
          "zsh",
      ],
  }
  return package_lists.get(distro.lower())

def install_packages(distro):
  """
  Installs the specified packages for the given distro.
  """
  package_list = _get_package_list(distro)
  if not package_list:
    print(f"Unsupported distro: {distro}")
    return

  # Use a single command for package installation based on distro
  if distro.lower() == "ubuntu":
    subprocess.run(["sudo", "apt", "install", "-y"] + package_list, check=True)
  elif distro.lower() == "arch":
    subprocess.run(["sudo", "pacman", "-S"] + package_list, check=True)
  elif distro.lower() == "fedora":
    subprocess.run(["sudo", "dnf", "install"] + package_list, check=True)
  else:
    print(f"Unsupported distro: {distro}")

def upgrade_packages(distro):
  """
  Upgrades the packages for the given distro.
  """
  if distro.lower() == "ubuntu":
    subprocess.run(["sudo", "apt", "update", "-y"])
    subprocess.run(["sudo", "apt", "upgrade", "-y"], check=True)
  elif distro.lower() == "arch":
    subprocess.run(["sudo", "pacman", "-Syu"], check=True)
  elif distro.lower() == "fedora":
    subprocess.run(["sudo", "dnf", "update"], check=True)
    subprocess.run(["sudo", "dnf", "upgrade"], check=True)
  else:
    print(f"Unsupported distro: {distro}")


def clone_dotconfig():
  """
  Clones the dotfiles repository from Github, offering options for backup or deletion of existing .config.
  """
  repo = "https://github.com/maithaen/.config.git"

  while True:
    choice = input("""
    .config directory exists. Please choose an option:
    1. Backup .config
    2. Delete .config (proceed with caution!)
    3. Exit cloning process
    Enter option: """)

    if choice not in ("1", "2", "3"):
      print("Invalid option. Please enter 1, 2, or 3.")
      continue

    if choice == "1":
      backup_dir = os.path.expanduser("~/.config_backup")
      try:
        # Create backup directory if it doesn't exist
        if not os.path.exists(backup_dir):
          os.makedirs(backup_dir)

        # Backup existing .config directory
        subprocess.run(["sudo", "cp", "-r", os.path.expanduser("~/.config"), backup_dir], check=True)
        print(f"Existing .config backed up to {backup_dir}")
        break  # Exit the loop after successful backup
      except subprocess.CalledProcessError as e:
        print(f"Error backing up .config: {e}")
        # Optionally offer to retry or exit

    elif choice == "2":
      confirmation = input("Are you sure you want to DELETE your existing .config directory? (y/N): ")
      if confirmation.lower() == "y":
        try:
          subprocess.run(["rm", "-rf", os.path.expanduser("~/.config")], check=True)
          print(".config directory deleted.")
          break  # Exit the loop after deletion
        except subprocess.CalledProcessError as e:
          print(f"Error deleting .config: {e}")
      else:
        print("Deletion cancelled.")

    elif choice == "3":
      print("Exiting cloning process.")
      return  # Exit the function entirely

  # Perform cloning logic after successful backup or deletion (existing from the loop)
  try:
    # Combine cloning and checkout into a single command
    subprocess.run(["git", "clone", repo, "~"])
    # Remove Git metadata directly after cloning
    subprocess.run(["sudo", "rm", "-rf", "~/.git"], check=True)
    # move .config/.zshrc to ~/.zshrc
    if os.path.exists(os.path.expanduser("~/.zshrc")) and os.path.exists(os.path.expanduser("~/.config/.zshrc")):
        os.rename(os.path.expanduser("~/.zshrc"), os.path.expanduser("~/.zshrc_backup"))
        print(".zshrc reanamed to .zshrc_backup")
        subprocess.run(["sudo", "mv", "~/.config/.zshrc", "~/.zshrc"], check=True)
        # source .zshrc
        print("Sourcing ~/.zshrc")
        subprocess.run(["source", "~/.zshrc"], check=False)

    else:
        subprocess.run(["mv", "~/.config/.zshrc", "~/.zshrc"], check=True)
    print(".dotfiles cloned successfully")
  except subprocess.CalledProcessError as e:
    print(f"Error cloning dotfiles: {e}")


def main():
  """
  Prompts the user for distro and option, then performs the chosen action.
  """
  while True:
    distro_choice = input("""
    Please select Linux distribution:
    1. Ubuntu/Debian
    2. Arch/Manjaro
    3. Fedora
    Enter option (or 'q' to quit): """)
    if distro_choice.lower() == 'q':
      break

    if distro_choice not in ("1", "2", "3"):
      print("Invalid option. Please enter 1, 2, 3 or 'q' to quit.")
      continue

    distro = ["ubuntu", "arch", "fedora"][int(distro_choice) - 1]

    while True:
        option_choice = input("""
        Please select option:
        1. Update packages
        2. Install packages
        3. Clone dotfiles
        4. Black <==
        Enter option (1, 2, 3, 4 or 'q' to quit): """)
        if option_choice.lower() == 'q':
            exit()
        elif option_choice not in ("1", "2", "3", "4"):
            print("Invalid option. Please enter 1, 2, 3, 4 or 'q' to quit.")
            continue
        if option_choice == "1":
            upgrade_packages(distro)
        elif option_choice == "2":
            install_packages(distro)
        elif option_choice == "3":
            clone_dotconfig()
        else:
            break




if __name__ == '__main__':
    main()