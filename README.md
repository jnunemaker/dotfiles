# My Dot Files

Clone the repository and run setup.

```bash
git clone https://github.com/jnunemaker/dotfiles.git ~/.dotfiles
~/.dotfiles/script/setup
```

Setup installs Homebrew when needed, installs missing packages from the
`Brewfile` (including Git) without upgrading existing packages, and symlinks
the managed configuration files.

The `Brewfile` also declares the desktop apps and developer tools used on each
Mac. Setup preserves existing non-Homebrew installations and uses Homebrew only
when an app or command is missing. Apps still require their normal first-run
sign-in and macOS permission prompts.

Gstack is installed from its official Git repository after its Homebrew
dependencies are available.
