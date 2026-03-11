#!/usr/bin/env bash
# Slack as web app

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_slack() {
    log_info "Installing Slack as a web app..."

    # Remove snap version if exists
    if snap list slack &>/dev/null; then
        log_info "Removing Slack snap..."
        sudo snap remove slack
    fi

    # Remove deb version if exists
    if dpkg -l | grep -q slack-desktop; then
        log_info "Removing Slack desktop..."
        sudo apt remove -y slack-desktop
    fi

    # Create webapp directories
    mkdir -p ~/.local/share/webapps/slack-chrome-profile
    mkdir -p ~/.local/share/applications

    # Create desktop entry
    cat > ~/.local/share/applications/slack-webapp.desktop << 'SLACKEOF'
[Desktop Entry]
Version=1.0
Name=Slack
Comment=Slack Web App
Exec=google-chrome --app=https://app.slack.com --class=SlackWebApp --user-data-dir=~/.local/share/webapps/slack-chrome-profile --no-first-run --disable-infobars --disable-session-crashed-bubble
Icon=slack
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
StartupWMClass=SlackWebApp
SLACKEOF

    log_success "Slack web app installed"
    log_info "Launch with: rofi/dmenu -> 'Slack'"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_slack || true
