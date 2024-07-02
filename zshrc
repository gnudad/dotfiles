export HISTSIZE=100000
export SAVEHIST=$HISTSIZE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
export EDITOR=nvim

alias v="nvim $1"
alias s="kitten ssh"

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

zinit light sindresorhus/pure
zinit light jeffreytse/zsh-vi-mode
zinit light trystan2k/zsh-tab-title
zinit light MichaelAquilina/zsh-autoswitch-virtualenv
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit ice lucid wait
zinit snippet OMZP::fzf
zinit light Aloxaf/fzf-tab

if [[ $(uname) == "Darwin" ]]; then
    if [[ ! -d /opt/homebrew ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        brew bundle --file=~/dotfiles/Brewfile
    fi
    if [[ ! -d ~/dotfiles ]]; then
        git clone git@github.com:gnudad/dotfiles.git ~/dotfiles
        ln -sf ~/dotfiles/zshrc ~/.zshrc
    fi
    if [[ ! -d ~/.config/hammerspoon ]]; then
        defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
        mkdir -p ~/.config/hammerspoon/Spoons
        ln -sf ~/dotfiles/hammerspoon.lua ~/.config/hammerspoon/init.lua
        cd ~/.config/hammerspoon/Spoons
        git clone https://github.com/jasonrudolph/ControlEscape.spoon.git ~/.config/hammerspoon/Spoons/ControlEscape.spoon
    fi
    if [[ ! -d ~/.config/kitty ]]; then
        mkdir -p ~/.config/kitty
        ln -sf ~/dotfiles/kitty.conf ~/.config/kitty/kitty.conf
        echo "action launch --type=os-window -- \$EDITOR -- \$FILE_PATH" > ~/.config/kitty/launch-actions.conf
    fi
    if [[ ! -d ~/.config/nvim ]]; then
        mkdir -p ~/.config/nvim
        ln -sf ~/dotfiles/neovim.lua ~/.config/nvim/init.lua
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ $(uname) == "Linux" ]]; then
    # TODO
fi

autoload -Uz compinit
compinit
eval "$(zoxide init zsh)"
