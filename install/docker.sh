#!/usr/bin/env bash
# Docker and Docker Compose installation

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_docker() {
    if has docker; then
        log_success "Docker already installed"
        return
    fi

    log_info "Installing Docker..."

    case "$OS" in
        debian)
            # Remove old versions
            sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

            # Install dependencies
            pkg_install ca-certificates gnupg lsb-release

            # Add Docker GPG key
            sudo install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            sudo chmod a+r /etc/apt/keyrings/docker.gpg

            # Add Docker repository
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            sudo apt-get update
            pkg_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        fedora)
            sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            pkg_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        arch)
            pkg_install docker docker-compose
            ;;
    esac

    # Add user to docker group
    sudo usermod -aG docker "$USER"

    # Enable and start Docker
    sudo systemctl enable docker
    sudo systemctl start docker

    log_success "Docker installed (log out and back in to use without sudo)"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_docker || true
