# .config file

* Neovim         :[Neovim](https://github.com/maithaen/.config/tree/main/nvim)

# Install Neovim

```bash
cd && git clone https://github.com/maithaen/.config.git
```
# window
## install git
```bash
winget install Git.Git
```
## install nodejs and yarn
```bash
winget install OpenJS.NodeJS && npm -install -g yarn
```
# config coc plugin
## change folder to coc.nvim
```bash
cd ~/.config/nvim/autoload/plugs/coc.nvim
```
## window install by chocolatey if you not install nodejs and yarn
```bash
choco install nodejs -y && npm -install -g yarn
```
## or

```bash
yarn build
```
