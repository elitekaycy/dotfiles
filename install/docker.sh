#!/usr/bin/env bash
# Docker and Docker Compose installation

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_docker() {
    local login_user="${SUDO_USER:-${USER:-$(id -un)}}"

    if has docker; then
        log_success "Docker already installed"
        return
    fi

    log_info "Installing Docker..."

    case "$OS" in
        debian)
            local docker_distro
            local docker_codename
            # shellcheck disable=SC1091
            source /etc/os-release

            case "$ID" in
                debian)
                    docker_distro="debian"
                    docker_codename="$VERSION_CODENAME"
                    ;;
                ubuntu)
                    docker_distro="ubuntu"
                    docker_codename="$VERSION_CODENAME"
                    ;;
                pop|linuxmint)
                    docker_distro="ubuntu"
                    docker_codename="${UBUNTU_CODENAME:-$VERSION_CODENAME}"
                    ;;
                *)
                    log_error "Docker repository is not configured for distro ID '$ID'."
                    return 1
                    ;;
            esac

            sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
            pkg_install ca-certificates gnupg

            sudo install -m 0755 -d /etc/apt/keyrings
            curl -fsSL "https://download.docker.com/linux/$docker_distro/gpg" | \
                sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
            sudo chmod a+r /etc/apt/keyrings/docker.gpg

            printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/%s %s stable\n' \
                "$(dpkg --print-architecture)" "$docker_distro" "$docker_codename" | \
                sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

            sudo apt-get update
            pkg_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        fedora)
            sudo curl -fsSL https://download.docker.com/linux/fedora/docker-ce.repo \
                -o /etc/yum.repos.d/docker-ce.repo
            pkg_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        arch)
            pkg_install docker docker-compose
            ;;
    esac

    sudo usermod -aG docker "$login_user"
    sudo systemctl enable --now docker

    log_success "Docker installed (log out and back in to use without sudo)"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_docker || true
