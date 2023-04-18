# .config file

* Neovim         :[Neovim](https://github.com/maithaen/.config/tree/main/nvim)


# 1.window
## Install packages
### 1)Install Neovim
```bash
winget install Neovim.Neovim
```
### 2)install git
```bash
winget install Git.Git
```
### 3)install nodejs and yarn
```bash
winget install OpenJS.NodeJS
```

## Or
### window install by chocolatey 
```bash
choco install git.install nodejs.install neovim -y 
```
# 2.Linux (Debian)
## Install packages
```bash
sudo apt-get install neovim git nodejs npm -y 
```
# 3.Config Nvim
## Backup the .config/nvim
```bash
cp ~/.config/nvim/init.vim ~/.config/nvim/init.vim.bak
```
## Restore the .config/nvim
```bash
cp ~/.config/nvim/init.vim.bak ~/.config/nvim/init.vim
```
## clone .config/nvim
```bash
cd && git clone https://github.com/maithaen/.config.git
```

# config coc plugin
## change folder to coc.nvim
```bash
cd ~/.config/nvim/autoload/plugs/coc.nvim
```
```bash
npm install --global yarn
```
```bash
yarn install
```




