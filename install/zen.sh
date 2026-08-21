#!/usr/bin/env bash
# Zen browser: install Vimium via an enterprise policy so vim keys work on first launch.

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

install_zen_policy() {
    local zen_bin zen_dir policy
    zen_bin="$(command -v zen || true)"
    [[ -n "$zen_bin" ]] || { log_warn "zen is not installed; skipping browser policy"; return 0; }
    zen_dir="$(dirname "$(readlink -f "$zen_bin")")"
    policy="$(dirname "${BASH_SOURCE[0]}")/zen-policies.json"

    log_info "Installing Zen policy (Vimium) into $zen_dir/distribution"
    sudo mkdir -p "$zen_dir/distribution"
    sudo cp "$policy" "$zen_dir/distribution/policies.json"
    log_success "Zen policy installed; restart Zen"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && install_zen_policy || true
