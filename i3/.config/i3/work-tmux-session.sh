#!/bin/bash

# Create or attach to work tmux session
SESSION_NAME="work"

# Check if session already exists
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    # If session exists, just attach to it
    tmux attach-session -t $SESSION_NAME
else
    # Create new session with first window named "work"
    tmux new-session -d -s $SESSION_NAME -n "work"

    # Set the working directory to current directory for work tab
    tmux send-keys -t $SESSION_NAME:work "cd $(pwd)" C-m

    # Open code editor in work tab
    tmux send-keys -t $SESSION_NAME:work "pvim ." C-m

    # Create docs window
    tmux new-window -t $SESSION_NAME -n "docs"
    tmux send-keys -t $SESSION_NAME:docs "cd $(pwd)" C-m

    # Create script window
    tmux new-window -t $SESSION_NAME -n "script"
    tmux send-keys -t $SESSION_NAME:script "cd $(pwd)" C-m

    # Create claude research window
    tmux new-window -t $SESSION_NAME -n "claude-research"
    tmux send-keys -t $SESSION_NAME:claude-research "cd $(pwd)" C-m

    # Select the work window (first tab) as default
    tmux select-window -t $SESSION_NAME:work

    # Attach to the session
    tmux attach-session -t $SESSION_NAME
fi
