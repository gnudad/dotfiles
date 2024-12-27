export HISTSIZE=100000
export SAVEHIST=$HISTSIZE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
export EDITOR=nvim

alias ls="ls --color"
alias ll="ls -al"
alias lt="ll -t | less -FR"
alias s="kitten ssh"
alias uuid="uuidgen | tr '[:upper:]' '[:lower:]' | tee >(pbcopy)"
function mkcd() { mkdir -p "$@" && cd "$@"; }
function v() {
    nvim $1
    if [[ -f /tmp/.oil.nvim.cd ]]; then
        cd $(cat /tmp/.oil.nvim.cd)
        rm /tmp/.oil.nvim.cd
    fi
}

# Bootstrap Zinit plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
declare -A ZINIT; ZINIT[NO_ALIASES]=1; source "${ZINIT_HOME}/zinit.zsh"

# Plugins
zinit light sindresorhus/pure
zinit light jeffreytse/zsh-vi-mode
zinit light MichaelAquilina/zsh-autoswitch-virtualenv
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit ice lucid wait
zinit snippet OMZP::fzf
zinit light Aloxaf/fzf-tab

# Plugin config
export FZF_DEFAULT_OPTS="--bind 'tab:accept'"
zstyle ':fzf-tab:*' fzf-bindings 'tab:accept'
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

if [[ $(uname) == "Darwin" ]]; then
    if [[ ! -d /opt/homebrew ]]; then
        xcode-select --install
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        brew bundle --file=~/.dotfiles/Brewfile
        curl -L "https://www.python.org/ftp/python/2.7.18/python-2.7.18-macosx10.9.pkg" \
            --output ~/Downloads/python-2.7.18-macosx10.9.pkg
        open -W ~/Downloads/python-2.7.18-macosx10.9.pkg
        rm /usr/local/bin/python
        rm /usr/local/bin/pip
    fi
    if [[ ! -d ~/.dotfiles ]]; then
        git clone git@github.com:gnudad/dotfiles.git ~/.dotfiles
        git config --global core.excludesFile ~/.dotfiles/.gitignore
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
        ln -sf ~/.dotfiles/snippets ~/.config/nvim/snippets
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"

elif [[ $(uname) == "Linux" ]]; then
    zinit ice from"gh-r" as"program"; zinit light junegunn/fzf
    if [[ $(ldd --version | grep -Eo '(2\.[0-9]+)$') > "2.30" ]]; then
        zinit ice from"gh-r" as"program" pick"nvim*/bin/nvim"; zinit light neovim/neovim
    else
        zinit ice from"gh-r" as"program" pick"nvim*/bin/nvim"; zinit light neovim/neovim-releases
    fi
    zinit ice from"gh-r" as"program" pick"ripgrep*/rg"; zinit light BurntSushi/ripgrep
    zinit ice from"gh-r" as"program"; zinit light ajeetdsouza/zoxide
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
