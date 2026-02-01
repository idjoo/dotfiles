---
name: tmux
description: Manage tmux sessions for background processes, parallel terminals, and persistent command execution.
compatibility: opencode
metadata:
  workflow: terminal
---

# tmux Session Management

Manage persistent terminal sessions for long-running processes and parallel workspaces.

## When to Use

| Scenario | Use tmux? |
|----------|-----------|
| Long-running build/test | Yes |
| Process needs to survive disconnection | Yes |
| Parallel terminal workspaces needed | Yes |
| Quick one-off command | No |
| Command completes in seconds | No |

## Quick Reference

```bash
# Check sessions
tmux list-sessions 2>/dev/null || echo "No sessions"

# Create session + run command
tmux new-session -d -s "name" && tmux send-keys -t "name" "command" Enter

# Capture output
tmux capture-pane -t "name" -p

# Kill session
tmux kill-session -t "name"
```

## Session Operations

### Create

```bash
tmux new-session -d -s "session-name"           # Detached
tmux new-session -A -s "session-name"           # Create or attach
```

### Execute Commands

```bash
tmux send-keys -t "session" "command" Enter     # Run in session
tmux send-keys -t "session:window" "cmd" Enter  # Specific window
tmux send-keys -t "session:0.0" "cmd" Enter     # Specific pane
```

### Capture Output

```bash
tmux capture-pane -t "session" -p               # Current screen
tmux capture-pane -t "session" -p -S -1000      # Last 1000 lines
```

### Windows and Panes

```bash
tmux new-window -t "session" -n "window-name"   # New window
tmux split-window -h -t "session"               # Split horizontal
tmux split-window -v -t "session"               # Split vertical
tmux list-windows -t "session"                  # List windows
tmux list-panes -t "session"                    # List panes
```

### Cleanup

```bash
tmux kill-session -t "session-name"             # Kill session
tmux kill-server                                # Kill all
```

## Common Patterns

### Background Build

```bash
tmux new-session -d -s "build" && \
tmux send-keys -t "build" "npm run build" Enter
```

### Check Status

```bash
tmux capture-pane -t "build" -p | tail -20
```

### Dev Environment

```bash
tmux new-session -d -s "dev" && \
tmux send-keys -t "dev" "npm run dev" Enter && \
tmux new-window -t "dev" -n "logs" && \
tmux send-keys -t "dev:logs" "tail -f logs/app.log" Enter
```

## Best Practices

1. **Check first**: Always verify session exists before creating
2. **Descriptive names**: Use `build`, `dev`, `logs` not `s1`, `s2`
3. **Capture output**: Verify command results with `capture-pane`
4. **Clean up**: Kill sessions when work is complete
5. **Chain commands**: Use `&&` for proper sequencing
