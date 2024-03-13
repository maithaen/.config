
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




