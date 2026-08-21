#!/usr/bin/env bash
# pass (the standard unix password manager): package, GPG key, git-backed store.

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_pass() {
    local name email key

    if ! has pass; then
        log_info "Installing pass..."
        case "$OS" in
            debian) pkg_install pass ;;
            fedora) pkg_install pass ;;
            arch) pkg_install pass ;;
        esac
    fi

    # GPG key: reuse the first secret key, otherwise create one for the git identity.
    key="$(gpg --list-secret-keys --with-colons 2>/dev/null | awk -F: '$1 == "sec" { print $5; exit }')"
    if [[ -z "$key" ]]; then
        name="$(git config --global user.name || echo "$USER")"
        email="$(git config --global user.email || echo "$USER@$(hostname)")"
        log_info "Creating a GPG key for $name <$email> (you will be asked for a passphrase)"
        gpg --quick-generate-key "$name <$email>" ed25519 cert,sign never
        key="$(gpg --list-secret-keys --with-colons | awk -F: '$1 == "sec" { print $5; exit }')"
        gpg --quick-add-key "$key" cv25519 encr never
    fi
    [[ -n "$key" ]] || { log_error "No GPG key available; run: gpg --full-generate-key"; return 1; }

    if [[ ! -f "$HOME/.password-store/.gpg-id" ]]; then
        log_info "Initialising the password store with key $key"
        pass init "$key" >/dev/null
        pass git init >/dev/null 2>&1 || true
    fi

    # Cache the passphrase for a working day so scripts do not keep prompting.
    mkdir -p "$HOME/.gnupg"
    chmod 700 "$HOME/.gnupg"
    if ! grep -q '^default-cache-ttl' "$HOME/.gnupg/gpg-agent.conf" 2>/dev/null; then
        printf 'default-cache-ttl 28800\nmax-cache-ttl 86400\n' >> "$HOME/.gnupg/gpg-agent.conf"
        gpgconf --kill gpg-agent 2>/dev/null || true
    fi

    log_success "pass ready: $(pass ls 2>/dev/null | head -1)"
    log_info "Sync to a private repo: pass git remote add origin <url> && dots-secret sync"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_pass || true
