
# install oh-my-zsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```


# install zsh Plugings
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```
###### add config to your  ~/.zshrc
```bash
plugins=(
        git
        zsh-autosuggestions
        zsh-syntax-highlighting
)
```
# config nvim
## install vim pluggins

###### Unix, Linux

```sh
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```
```sh
mkdir -p .config/nvim/init.vim && cd $_
```
### coppy init.vim to .config/nvim/  and run :PlugInstall in neovim

## config coc plugin
### change folder to coc.nvim

```bash
npm install --ignore-engines
```
```bash
yarn install --ignore-engines
```

# install apps list: 
  "neovim", "git", "zsh",
  "oh-my-zsh", "curl", "wget", "python3",
  "python3-pip", "python3-venv", "gcc", "g++",
  "make", "cmake", "neofetch",
  "adb", "fastboot"
## Install apps using apt
```bash
sh -c "$(curl -fsSL https://github.com/maithaen/.config/blob/main/install_apps_using_apt.sh)"
```
## Install  apps using pacman
```bash
sh -c "$(curl -fsSL https://github.com/maithaen/.config/blob/main/install_apps_using_pacman.sh)"
```






