# My Dot Files

Clone the repository and run setup.

```bash
git clone https://github.com/jnunemaker/dotfiles.git ~/.dotfiles
~/.dotfiles/script/setup
```

Setup installs Bun, Claude Code, and Codex with their official user-local
installers when they are missing. It then installs Homebrew when needed,
installs missing packages from the `Brewfile` (including Git) without upgrading
existing packages, and symlinks the managed configuration files.

The `Brewfile` also declares the desktop apps and developer tools used on each
Mac. Setup preserves existing installations and uses Homebrew for software that
does not have a suitable first-party, user-local installer. Apps still require
their normal first-run sign-in and macOS permission prompts.

Gstack is installed from its official Git repository after its Homebrew
dependencies are available.

Git and the external tools referenced by `.gitconfig` are managed by the
`Brewfile`, including Delta, Git LFS, GitHub CLI, Heroku CLI, and GnuPG.
Diffity is installed globally through npm.
