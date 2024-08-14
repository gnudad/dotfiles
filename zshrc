export HISTSIZE=100000
export SAVEHIST=$HISTSIZE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
export EDITOR=nvim

alias v="nvim $1"
alias s="kitten ssh"
alias ls="ls --color"
alias ll="ls -al"
alias lt="ll -t | less -FR"
function mkcd() { mkdir -p "$@" && cd "$@"; }

# Bootstrap Zinit plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Plugins
zinit light sindresorhus/pure
zinit light jeffreytse/zsh-vi-mode
zinit light trystan2k/zsh-tab-title
zinit light MichaelAquilina/zsh-autoswitch-virtualenv
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit ice lucid wait
zinit snippet OMZP::fzf
zinit light Aloxaf/fzf-tab

# Plugin config
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

if [[ $(uname) == "Darwin" ]]; then
    if [[ ! -d /opt/homebrew ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        brew bundle --file=~/.dotfiles/Brewfile
    fi
    if [[ ! -d ~/.dotfiles ]]; then
        git clone git@github.com:gnudad/dotfiles.git ~/.dotfiles
        ln -sf ~/.dotfiles/zshrc ~/.zshrc
        touch ~/.hushlogin
    fi
    if [[ ! -d ~/.config/hammerspoon ]]; then
        defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
        mkdir -p ~/.config/hammerspoon
        ln -sf ~/.dotfiles/hammerspoon.lua ~/.config/hammerspoon/init.lua
    fi
    if [[ ! -d ~/.config/kitty ]]; then
        mkdir -p ~/.config/kitty
        ln -sf ~/.dotfiles/kitty.conf ~/.config/kitty/kitty.conf
        echo "protocol file" > ~/.config/kitty/launch-actions.conf
        echo "action launch --type=os-window -- \$EDITOR -- \$FILE_PATH" >> ~/.config/kitty/launch-actions.conf
    fi
    if [[ ! -d ~/.config/nvim ]]; then
        mkdir -p ~/.config/nvim
        ln -sf ~/.dotfiles/neovim.lua ~/.config/nvim/init.lua
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"

elif [[ $(uname) == "Linux" ]]; then
    zi ice from"gh-r" as"program"; zi light junegunn/fzf
    zi ice from"gh-r" as"program" pick"nvim*/bin/nvim"; zi light neovim/neovim
    zi ice from"gh-r" as"program" pick"rg/rg"; zi light BurntSushi/ripgrep
    zi ice from"gh-r" as"program"; zi light ajeetdsouza/zoxide
    if [[ ! -d ~/.dotfiles ]]; then
        git clone https://github.com/gnudad/dotfiles.git ~/.dotfiles
        ln -sf ~/.dotfiles/zshrc ~/.zshrc
        rm -rf ~/.config/nvim
    fi
    if [[ ! -d ~/.config/nvim ]]; then
        mkdir -p ~/.config/nvim
        ln -sf ~/.dotfiles/neovim.lua ~/.config/nvim/init.lua
    fi
fi

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # smartcase completion
eval "$(zoxide init zsh)"
