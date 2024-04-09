
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
```sh
plugins=(
        git
        zsh-autosuggestions
        zsh-syntax-highlighting
)
```
# config nvim
## install nvim pluggins Linux

```sh
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```
```sh
mkdir -p .config/nvim/ && cd $_ && touch init.vim
```
### coppy init.vim to .config/nvim/  and run :PlugInstall in neovim
##Install nvm, node and yarn
```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && source ~/.zshrc && nvm install node && npm install yarn -g
```
#Install Plugin
```sh
nvim +PlugInstall
```

## config coc plugin
### change folder to coc.nvim


```bash
cd .local/share/nvim/plugged/coc.nvim && yarn install --ignore-engines
```

# install apps list: 
neovim git zsh oh-my-zsh curl wget python3 python3-pip python3-venv gcc g++ make cmake neofetch adb fastboot
## Install apps uscript python


```bash
in comming soon
```
