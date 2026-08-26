# ~/.zshrc
# Sections: path · plugins · tools · tmux · fzf · aliases · completion

# --- Path -------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.grok/bin" ]] && export PATH="$HOME/.grok/bin:$PATH"
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac

setopt pushd_ignore_dups pushd_silent
export AWS_PROFILE=sandbox-elitekaycy
export BAT_THEME=tokyonight_night

# --- Plugins (znap) ---------------------------------------------------------
ZNAP_LOCATION=~/zsh-plugins/znap
[[ -r $ZNAP_LOCATION/znap.zsh ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git $ZNAP_LOCATION
source $ZNAP_LOCATION/znap.zsh

znap prompt sindresorhus/pure
znap source zsh-users/zsh-completions

# --- Tools (cached by znap eval) -------------------------------------------
if command -v mise &>/dev/null; then
    znap eval mise 'mise activate zsh'
    mise where java &>/dev/null && export JAVA_HOME="$(mise where java)" && export PATH="$JAVA_HOME/bin:$PATH"
    mise where tomcat &>/dev/null && export CATALINA_HOME="$(mise where tomcat)"
fi
[[ -f "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"
command -v atuin &>/dev/null && znap eval atuin 'atuin init zsh'
command -v zoxide &>/dev/null && znap eval zoxide 'zoxide init zsh'
command -v direnv &>/dev/null && znap eval direnv 'direnv hook zsh'
command -v ng &>/dev/null && znap eval ng 'ng completion script'
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && export SDKMAN_DIR="$HOME/.sdkman" && source "$HOME/.sdkman/bin/sdkman-init.sh"
[[ -f "$HOME/.config/broot/launcher/bash/br" ]] && source "$HOME/.config/broot/launcher/bash/br"
if [[ "${TERM_PROGRAM:-}" == "kiro" ]] && command -v kiro &>/dev/null; then
    . "$(kiro --locate-shell-integration-path zsh)"
fi
command -v pokemon-colorscripts &>/dev/null && pokemon-colorscripts --no-title -s -r

# --- tmux: attach or create "main" when opening a terminal ----------------
if command -v tmux &>/dev/null && [[ -z "$TMUX" ]]; then
    session_count=$(tmux ls 2>/dev/null | wc -l)
    if [[ $session_count -eq 0 ]]; then
        tmux new-session -s main
    elif [[ $session_count -eq 1 ]]; then
        tmux attach-session
    elif command -v fzf &>/dev/null; then
        session=$(tmux ls -F "#{session_name}: #{session_windows} windows (#{session_attached} attached)" |
            fzf --height=40% --reverse --header="Select tmux session" | cut -d: -f1)
        [[ -n "$session" ]] && tmux attach-session -t "$session" || tmux attach-session
    else
        tmux attach-session
    fi
    unset session_count session
fi

# --- fzf --------------------------------------------------------------------
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_compgen_path() { fd --hidden --exclude .git . "$1"; }
_fzf_compgen_dir() { fd --type=d --hidden --exclude .git . "$1"; }
_fzf_comprun() {
    local command=$1
    shift
    case "$command" in
        cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
        export|unset) fzf --preview "eval 'echo $'{}" "$@" ;;
        ssh)          fzf --preview 'dig {}' "$@" ;;
        *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
    esac
}

# Ctrl+g: live content search (dots-grep) in the current directory
if command -v dots-grep &>/dev/null; then
    dots-grep-widget() {
        dots-grep "" "$PWD" </dev/tty >/dev/tty
        zle reset-prompt
    }
    zle -N dots-grep-widget
    bindkey '^G' dots-grep-widget
fi

# --- Aliases ----------------------------------------------------------------
alias pvim='NVIM_APPNAME=pvim command nvim'
alias pvi='NVIM_APPNAME=pvim command nvim'
export EDITOR=pvim VISUAL=pvim
command -v bat &>/dev/null && alias cat="bat"
command -v eza &>/dev/null && alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias broot='br'
alias lsb='br'

# tmux
alias tn='tmux new-session -s'
alias ta='tmux attach-session -t'
alias tl='tmux ls'
alias tk='tmux kill-session -t'

# kubernetes (minikube)
alias kubectl="minikube kubectl --"
alias k="kubectl"
alias kpf="kubectl port-forward"
alias kaf="kubectl apply -f"
alias kdf="kubectl delete -f"

# docker
alias dps='docker ps --format "{{.Names}}\t{{.Ports}}\t{{.Image}}" | awk '\''BEGIN { printf "\033[1;34m%-25s\033[0m \033[1;32m%-40s\033[0m \033[1;36m%-20s\033[0m\n", "NAME", "PORTS", "IMAGE" }
    { printf "\033[1;34m%-25s\033[0m \033[1;32m%-40s\033[0m \033[1;36m%-20s\033[0m\n", $1, $2, $3 }'\'''
alias minio-setup="mc alias set local http://localhost:9000 minioadmin minioadmin"

# power
alias adios="sudo shutdown now"
alias aloha="sudo shutdown now"
alias sayanora="sudo shutdown now"
alias killmenow="sudo shutdown now"
alias shutdown="sudo shutdown now"
alias sss="sudo shutdown now"
alias reboot="sudo reboot"
alias rr="sudo reboot"

# --- Completion (keep last) ------------------------------------------------
[[ -d "$HOME/.grok/completions/zsh" ]] && fpath=("$HOME/.grok/completions/zsh" $fpath)
autoload -Uz compinit
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
compinit -C -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-syntax-highlighting   # must be last

# kimi-code
export PATH="/home/elitekaycy/.kimi-code/bin:$PATH"

# opencode
export PATH=/home/elitekaycy/.opencode/bin:$PATH
