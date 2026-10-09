# My Dot Files

Clone the repository and run setup.

```bash
git clone https://github.com/jnunemaker/dotfiles.git ~/.dotfiles
~/.dotfiles/script/setup
```

Setup is silent when everything works. If a step fails, it prints what it was
doing and that step's full output, then stops. Only steps that need you, such as
the Homebrew installer's password prompt or Codex's Cloudflare, Honeybadger, and
Help Scout sign-ins and the one-time Jelly and Fireside API token prompts, show their output as
they run. If setup replaces existing files, it says where it
moved them.

Setup installs Bun, Claude Code, Codex, and the T3 Code CLI (`t3`) with their
official user-local installers when they are missing. It then installs Homebrew when needed,
installs missing packages from the `Brewfile` (including Git) without upgrading
existing packages, and symlinks the managed configuration files.

The `Brewfile` also declares the desktop apps and developer tools used on each
Mac. Setup preserves existing installations and uses Homebrew for software that
does not have a suitable first-party, user-local installer. Apps still require
their normal first-run sign-in and macOS permission prompts.

Gstack is installed from its official Git repository after its Homebrew
dependencies are available.

Setup installs the Cloudflare and PlanetScale Claude Code plugins, which bring
their hosted MCP servers, and adds Cloudflare's MCP server to Codex. It also
adds the hosted Honeybadger and Help Scout (read-only) MCP servers to both
Claude Code and Codex. Each signs
in with OAuth the first time it is used. A Honeybadger sign-in grants a single
account and all its projects, so there is one server per account:
`honeybadger-boxout` (Box Out Sports), `honeybadger-nunes` (Nunes), and
`honeybadger-verygood` (Very Good Software). Pick the matching account when each
one signs in.

The hosted Jelly (`jelly`) and Fireside (`fireside`) MCP servers have no OAuth
and take an API token instead (in Jelly, Settings → API Tokens; Fireside's start
with `fire_`). Setup reads each from that Mac's login Keychain
(`jelly-api-token`, `fireside-api-token`), then from `JELLY_API_TOKEN` or
`FIRESIDE_API_TOKEN`, then asks when run in a terminal, and saves it to the
Keychain. With no token it skips that server with a note instead of waiting, so
setup never hangs on it. Setup then gives it to Claude Code and Codex as a bearer
header in their local configs, never in this repo. To change a token, delete the
Keychain item and the server from both tools, then rerun setup.

Railway is installed with its recommended installer (`railway.com/install.sh
--agents --local`), which also adds its agent skills and the local `railway mcp`
server. Setup removes a Homebrew `railway` if one is present.

mise manages language versions and is installed with its official installer
(`mise.run`) into `~/.local/bin`; setup replaces a Homebrew `mise` if one is
present. Global versions live in `mise/config.toml`, which setup links to
`~/.config/mise/config.toml` before running `mise install`. A leftover
`~/.tool-versions` is moved to the backup so it cannot override them. Projects
still pick their own versions from `.tool-versions` or `.ruby-version`.

Git and the external tools referenced by `.gitconfig` are managed by the
`Brewfile`, including Delta (the pager), hunk (for reviewing agent changes), Git LFS, GitHub CLI, Heroku CLI, and GnuPG.
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
