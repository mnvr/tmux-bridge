# tmux-bridge

A shared tmux session for human-agent collaboration. One binary handles session lifecycle (for the human) and pane coordination (for agents).

## Install

Requires macOS and `tmux` (`brew install tmux`).

```sh
curl -fsSL https://raw.githubusercontent.com/mnvr/tmux-bridge/main/install.sh | sh
```

This installs the `tmux-bridge` binary to `~/.local/bin` and the agent skill to `~/.local/share/tmux-bridge`.

Then add the skill to your project so your agent knows how to use the bridge:

```sh
mkdir -p .agents/skills
cp -r ~/.local/share/tmux-bridge .agents/skills/
```

For user-wide install, copy to `~/.codex/skills/` or `~/.claude/skills/` instead.

Claude Code will prompt for approval on each subcommand separately. To auto-approve all `tmux-bridge` commands, add to `.claude/settings.json` (project) or `~/.claude/settings.json` (user-wide):

```json
{
  "permissions": {
    "allow": ["Bash(tmux-bridge *)"]
  }
}
```

## Usage

### Human: start and stop the session

```sh
tmux-bridge start    # creates session, attaches
tmux-bridge stop     # kills session
```

The session name is derived from the git repo name. Each repo gets its own isolated tmux session and socket. If you're not in a git repo, the session is tied to whichever directory you start from.

### Agent: coordinate through the session

```sh
tmux-bridge list                        # list all panes
tmux-bridge label codex                 # name the current pane
tmux-bridge split claude claude         # split a new pane, start claude
tmux-bridge read claude 20              # read last 20 lines from a pane
tmux-bridge message claude "hello"      # send a bridge-formatted message
tmux-bridge keys claude Enter           # send keystrokes
tmux-bridge type worker "y"             # send literal text
```

## How it works

- Each project gets its own tmux socket at `/tmp/tmux-bridge/<hash>/bridge.sock`, keyed by the absolute path of the project root.
- The human starts the session from an ordinary terminal. Agents run bridge commands from inside the session's panes.
- `message` prepends a header (`[tmux-bridge from:<name> pane:<id> at:<location>]`) so the receiving agent knows who sent it and where to reply.
- The tmux config is embedded in the binary.

## Related

- [smux](https://github.com/ShawnPana/smux) inspired tmux-bridge, but I wanted something more minimal.
