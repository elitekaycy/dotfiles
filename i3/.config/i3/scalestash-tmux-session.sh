#!/bin/bash

# Create or attach to scalestash tmux session
SESSION_NAME="scalestash"

# Check if session already exists
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    # If session exists, just attach to it
    tmux attach-session -t $SESSION_NAME
else
    # Create new session with first window named "scalestash-landing"
    tmux new-session -d -s $SESSION_NAME -n "scalestash-landing"

    # Set the working directory for scalestash-landing
    tmux send-keys -t $SESSION_NAME:scalestash-landing "cd ~/Desktop/project/scale-app-projects/scale-app-api-landing" C-m
    tmux send-keys -t $SESSION_NAME:scalestash-landing "pvim ." C-m

    # Create scalestash-agentic-api window
    tmux new-window -t $SESSION_NAME -n "scalestash-agentic-api"
    tmux send-keys -t $SESSION_NAME:scalestash-agentic-api "cd ~/Desktop/project/scale-app-projects/scale-app-api-agentic/scale-app-api/scale-app-api" C-m
    tmux send-keys -t $SESSION_NAME:scalestash-agentic-api "pvim ." C-m

    # Create scalestash-agentic-web window
    tmux new-window -t $SESSION_NAME -n "scalestash-agentic-web"
    tmux send-keys -t $SESSION_NAME:scalestash-agentic-web "cd ~/Desktop/project/scale-app-projects/scale-app-web-agentic/scale-app-frontend" C-m
    tmux send-keys -t $SESSION_NAME:scalestash-agentic-web "pvim ." C-m

    # Create docs window
    tmux new-window -t $SESSION_NAME -n "docs"
    tmux send-keys -t $SESSION_NAME:docs "cd ~/Desktop/project/scale-app-projects" C-m

    # Create script window
    tmux new-window -t $SESSION_NAME -n "script"
    tmux send-keys -t $SESSION_NAME:script "cd ~/Desktop/project/scale-app-projects" C-m

    # Create claude research window
    tmux new-window -t $SESSION_NAME -n "claude-research"
    tmux send-keys -t $SESSION_NAME:claude-research "cd ~/Desktop/project/scale-app-projects" C-m

    # Select the scalestash-landing window (first tab) as default
    tmux select-window -t $SESSION_NAME:scalestash-landing

    # Attach to the session
    tmux attach-session -t $SESSION_NAME
fi