```bash
if [[ -f ~/.zshrc ]]; then mv ~/.zshrc ~/.zshrc_old; fi
curl https://raw.githubusercontent.com/gnudad/dotfiles/main/zshrc > ~/.zshrc
exec zsh
```
