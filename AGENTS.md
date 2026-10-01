These dotfiles set up both of my Macs, a MacBook Pro and a MacBook Air, with
`script/setup`. Every change must work on both machines, so don't hard-code
anything specific to one Mac (hostnames, hardware, paths outside `$HOME`).

Everything set up here must work in both Codex and Claude Code. When adding
an MCP server, skill, or other agent tooling, configure it for both tools, the
same way setup already handles Cloudflare and Honeybadger.

Never commit tokens, API keys, passwords, or other secrets to this repo. Keep
them out of tracked files, including the README and examples. Store a secret in
the Mac's login Keychain (or sign in with OAuth when the service supports it)
and have `script/setup` read it from there into the tool's local config.

Setup must never hang or block on a missing secret. Always give a workaround:
read the secret from the Keychain, then from an environment variable, then ask
only when running in a terminal; otherwise skip that step with a one-line note
on how to add it later, and keep going.
