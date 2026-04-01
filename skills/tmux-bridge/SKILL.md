---
name: tmux-bridge
description: Coordinate with other agents in a shared tmux session. Use when asked to communicate across panes, inspect panes, or collaborate with other agents through tmux.
---

# tmux-bridge

Use this skill when the human asks agents to coordinate through a shared tmux session.

## Prerequisites

The `tmux-bridge` binary must be on PATH.

The human starts the session with `tmux-bridge start` and stops it with `tmux-bridge stop`. The session name is derived from the current git repo (or directory) name.

## Permissions

When running any `tmux-bridge` command via Bash, request approval for the `tmux-bridge` prefix (not the individual subcommand) so that all subsequent bridge commands are auto-approved.

## Commands

- `tmux-bridge list`
- `tmux-bridge label <name>`
- `tmux-bridge split <label> [command...]`
- `tmux-bridge read <target> [lines]`
- `tmux-bridge message <target> <text>`
- `tmux-bridge keys <target> <key> [key...]`
- `tmux-bridge type <target> <text>`

Notes:
- `message` and `type` put text into the target pane but do not submit it.
- `keys` sends special keys such as `Enter`.


## Collaboration

- Keep bridge messages short — one or two sentences.
- For anything substantive (reviews, analysis, plans, code), write to a `/tmp/` file and send a pointer in the message.
- Use `read`, `message`, and `keys` for agent-to-agent communication.
- `message` and `keys ... Enter` are a strict sequential pair, not a parallel batch.
- After `keys ... Enter`, `read` once to verify submission, then stop reading the target pane.
- Replies arrive in your own pane. Do not poll the target pane for progress or reply.
- Treat the other agent as a collaborator, not a synchronous tool call.
- Send one bounded request. Do not keep tightening, reformulating, or re-sending while the other agent may still be working.
- If you are blocked on the reply, wait on the order of minutes, not seconds.
- If you are not blocked, do non-overlapping local work while you wait.

## Starting Another Agent And Handshaking

1. `list` panes.
2. If the target pane does not exist, `split <label> <launcher>`.
3. `read` the target pane.
4. `message` a short handshake. The other agent will see the bridge header and know how to reply — no need to explain `tmux-bridge` usage to it.
5. `keys ... Enter`.
6. `read` once to verify the prompt was actually submitted, then stop reading the target pane.

Use `type` for low-level control or non-agent panes. `read` is optional orientation.

## Examples

Inspect the current panes:

```sh
tmux-bridge list
```

Label the current pane:

```sh
tmux-bridge label codex
```

Create a new pane and start a command there:

```sh
tmux-bridge split claude claude
```

Message another agent:

```sh
tmux-bridge read claude 20
tmux-bridge message claude "Please review the current tmux bridge workflow."
tmux-bridge keys claude Enter
tmux-bridge read claude 20
```

Start Claude in a new pane, then do a minimal handshake:

```sh
tmux-bridge list
tmux-bridge split claude claude
tmux-bridge read claude 20
tmux-bridge message claude "Hi, please review the changes in /tmp/review-request.md"
tmux-bridge keys claude Enter
tmux-bridge read claude 20
```

Read and interact with a non-agent pane:

```sh
tmux-bridge read worker 20
tmux-bridge type worker "y"
tmux-bridge keys worker Enter
```
