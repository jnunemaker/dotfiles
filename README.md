# My Dot Files

Install homebrew and git.

```bash
# May want to check brew.sh for updated homebrew installation
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git
```

Setup dotfiles.

```bash
git clone https://github.com/jnunemaker/dotfiles.git ~/.dotfiles
~/.dotfiles/script/setup
brew bundle --global
```
