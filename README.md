# My Dot Files

Install homebrew and git.

```bash
# May want to check brew.sh for updated homebrew installation
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git
```

Setup dotfiles.

```bash
mkdir ~/bin
cd ~/bin
git clone git://github.com/jnunemaker/dotfiles.git
cd dotfiles
script/bootstrap
```
