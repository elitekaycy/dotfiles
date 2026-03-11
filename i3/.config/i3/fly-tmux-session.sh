#!/bin/bash

# Create or attach to fly tmux session (terminal on the fly)
SESSION_NAME="fly"

# Check if session already exists
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    # If session exists, just attach to it
    tmux attach-session -t $SESSION_NAME
else
    # Create new session with single window
    tmux new-session -d -s $SESSION_NAME -n "terminal"

    # Set the working directory to current directory
    tmux send-keys -t $SESSION_NAME:terminal "cd $(pwd)" C-m

    # Attach to the session
    tmux attach-session -t $SESSION_NAME
fi