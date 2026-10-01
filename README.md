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

Setup installs the Cloudflare and PlanetScale Claude Code plugins, which bring
their hosted MCP servers, and adds Cloudflare's MCP server to Codex. Each signs
in with OAuth the first time it is used.

Railway is installed with its recommended installer (`railway.com/install.sh
--agents --local`), which also adds its agent skills and the local `railway mcp`
server. Setup removes a Homebrew `railway` if one is present.

Git and the external tools referenced by `.gitconfig` are managed by the
`Brewfile`, including Delta, Git LFS, GitHub CLI, Heroku CLI, and GnuPG.
Diffity is installed globally through npm.

## Preferred microphone

Setup compiles `preferred-mic` and loads it as a LaunchAgent. Whenever a Shure
MV7 is connected, it stays the default microphone, even after AirPods or other
Bluetooth headphones connect and macOS switches input to them. When the Shure
is unplugged, macOS chooses the default input as usual. Audio output is left
alone, so headphones keep playing sound.

Apps that pick a specific microphone in their own settings ignore the system
default; set them to "System default" to follow it.

Switches are logged to `~/Library/Logs/preferred-mic.log`. To prefer a
different microphone, change the name prefix in
`preferred-mic/com.jnunemaker.preferred-mic.plist` and rerun setup. To pause
it until the next login:

```bash
launchctl bootout gui/$(id -u)/com.jnunemaker.preferred-mic
```
