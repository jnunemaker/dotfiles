# My Dot Files

Clone the repository and run setup.

```bash
git clone https://github.com/jnunemaker/dotfiles.git ~/.dotfiles
~/.dotfiles/script/setup
```

Setup is silent when everything works. If a step fails, it prints what it was
doing and that step's full output, then stops. Only steps that need you, such as
the Homebrew installer's password prompt or Codex's Cloudflare, Honeybadger, and
Help Scout sign-ins and the one-time Jelly, Fireside, and Ahrefs token prompts,
show their output as they run. If setup replaces existing files, it says where it
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
their hosted MCP servers, and adds the same Cloudflare and PlanetScale MCP
servers to Codex. It also
adds the hosted Honeybadger and Help Scout (read-only) MCP servers to both
Claude Code and Codex. Each signs
in with OAuth the first time it is used. A Honeybadger sign-in grants a single
account and all its projects, so there is one server per account:
`honeybadger-boxout` (Box Out Sports), `honeybadger-nunes` (Nunes), and
`honeybadger-verygood` (Very Good Software). Pick the matching account when each
one signs in.

The hosted Jelly (`jelly`), Fireside (`fireside`), and Crisp (`crisp`) MCP
servers have no OAuth and take an API token instead (in Jelly, Settings → API
Tokens; Fireside's start with `fire_`; in Crisp, Settings → Workspace Settings →
Advanced configuration → MCP Server Token, which also regenerates the
workspace's REST API tokens). Setup reads each from that Mac's login Keychain
(`jelly-api-token`, `fireside-api-token`, `crisp-mcp-token`), then from
`JELLY_API_TOKEN`, `FIRESIDE_API_TOKEN`, or `CRISP_MCP_TOKEN`, then asks when
run in a terminal, and saves it to the
Keychain. With no token it skips that server with a note instead of waiting, so
setup never hangs on it. Setup then gives it to Claude Code and Codex as a bearer
header in their local configs, never in this repo. To change a token, delete the
Keychain item and the server from both tools, then rerun setup.

The hosted Ahrefs MCP server (`ahrefs`) signs in with OAuth in Claude Code (run
`/mcp` and pick your Ahrefs workspace the first time). Codex refuses Ahrefs'
OAuth sign-in, so Codex uses an Ahrefs MCP key instead (an MCP key, not an API
v3 key). Setup handles it like the Jelly and Fireside tokens, using the Keychain
item `ahrefs-mcp-key` or `AHREFS_MCP_KEY`.

Setup adds `john_fireside` (the default) and `jnunemaker` profiles to
`~/.config/linode-cli`, each with a personal access token from
cloud.linode.com/profile/tokens. It reads tokens the same way, from the Keychain
items `linode-token-john_fireside` and `linode-token-jnunemaker`, then
`LINODE_TOKEN_JOHN_FIRESIDE` or `LINODE_TOKEN_JNUNEMAKER`, then asks. Profiles
already in the config are left alone, so to change a token, edit the config and
update the Keychain item.

Railway is no longer used. Setup removes the Railway CLI (Homebrew or
`~/.railway`), its `use-railway` agent skills, and the `railway` MCP server from
Claude Code and Codex if an earlier setup installed them.

mise manages language versions and is installed with its official installer
(`mise.run`) into `~/.local/bin`; setup replaces a Homebrew `mise` if one is
present. Global versions live in `mise/config.toml`, which setup links to
`~/.config/mise/config.toml` before running `mise install`. A leftover
`~/.tool-versions` is moved to the backup so it cannot override them. Projects
still pick their own versions from `.tool-versions` or `.ruby-version`.

T3 Code's settings live in `t3/settings.json` (server settings such as the
default model and enabled providers) and `t3/client-settings.json` (interface
preferences), and shortcuts live in `t3/keybindings.json`. Cmd+T opens the
in-app browser when the right panel is closed, and the right panel's new-tab
menu when it is open. T3 Code replaces these files when it saves, so setup copies them
into `~/.t3/userdata/` rather than linking them, backing up any that differ.
After changing settings in the app, run `t3-settings-save` to copy them back
here, then commit. Sign-ins, secrets, and threads stay on each Mac.

Git and the external tools referenced by `.gitconfig` are managed by the
`Brewfile`, including Delta (the pager), hunk (for reviewing agent changes), Git LFS, GitHub CLI, Heroku CLI, and GnuPG.
Diffity is installed globally through npm.

## Preferred microphone

Setup compiles `preferred-mic` and loads it as a LaunchAgent. Whenever a Shure
MV7 is connected, it stays the default microphone, even after AirPods or other
Bluetooth headphones connect and macOS switches input to them. Audio output is
left alone, so headphones keep playing sound.

When the Shure is unplugged, it still keeps input off Bluetooth headphones.
Using AirPods as a mic (for dictation, say) switches them from stereo music to
low-quality call audio, so it uses the MacBook's mic instead, or a wired mic
like a monitor's or a headset on the headphone jack when the lid is closed. If
there's no other mic, AirPods stay (or become) the input, since a closed lid
mutes the MacBook's mic.

Apps that pick a specific microphone in their own settings ignore the system
default; set them to "System default" to follow it.

Switches are logged to `~/Library/Logs/preferred-mic.log`. To prefer a
different microphone, change the name prefix in
`preferred-mic/com.jnunemaker.preferred-mic.plist` and rerun setup. To pause
it until the next login:

```bash
launchctl bootout gui/$(id -u)/com.jnunemaker.preferred-mic
```
