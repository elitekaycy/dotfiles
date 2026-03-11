#!/bin/bash
# Restore previous tmux session or create new one

SESSION="main"

# Check if tmux session exists
if tmux has-session -t "$SESSION" 2>/dev/null; then
    # Attach to existing session
    tmux attach-session -t "$SESSION"
else
    # Create new session
    tmux new-session -s "$SESSION"
fi
