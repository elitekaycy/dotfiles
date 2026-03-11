# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
# export ZSH="$HOME/.oh-my-zsh/strug.zsh-theme"


# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="strug"


export ZSH="$HOME/.oh-my-zsh"



# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(git)
# source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Display Pokemon-colorscripts (if installed)
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
command -v pokemon-colorscripts &>/dev/null && pokemon-colorscripts --no-title -s -r

ZNAP_LOCATION=~/zsh-plugins/znap
[[ -r $ZNAP_LOCATION/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git $ZNAP_LOCATION
source $ZNAP_LOCATION/znap.zsh  # Start Znap

# `znap prompt` makes your prompt visible in just 15-40ms!
znap prompt sindresorhus/pure

# `znap source` starts plugins.
znap source marlonrichert/zsh-autocomplete

# `znap install` adds new commands and completions.
znap install zsh-users/zsh-completions

# Load asdf if installed
[[ -f "$HOME/.asdf/asdf.sh" ]] && . "$HOME/.asdf/asdf.sh"

# Use bat as cat (if installed)
command -v batcat &>/dev/null && alias cat="batcat"
command -v bat &>/dev/null && alias cat="bat"


# TMUX SESSION EXIST OR CREATE
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    session_count=$(tmux ls 2>/dev/null | wc -l)

    if [[ $session_count -eq 0 ]]; then
        # No sessions - create "main"
        tmux new-session -s main
    elif [[ $session_count -eq 1 ]]; then
        # One session - attach to it
        tmux attach-session
    else
        # Multiple sessions - pick with fzf or fallback to last
        if command -v fzf &> /dev/null; then
            session=$(tmux ls -F "#{session_name}: #{session_windows} windows (#{session_attached} attached)" | \
                fzf --height=40% --reverse --header="Select tmux session" | \
                cut -d: -f1)
            [[ -n "$session" ]] && tmux attach-session -t "$session" || tmux attach-session
        else
            tmux attach-session
        fi
    fi
fi


#UPDATES START FROM HERE-------------------------------------------------------------------


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# source ~/fzf-git.sh/fzf-git.sh

export FZF_CTRL_T_OPTS="--preview 'batcat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "batcat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}

# ----- Bat (better cat) -----

export BAT_THEME=tokyonight_night
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"

# Kubectl sources
alias kubectl="minikube kubectl --"
alias kpf="kubectl port-forward"
alias k="kubectl"
alias kaf="kubectl apply -f"
alias kdf="kubectl delete -f"


# Source java from asdf to java home (if available)
if command -v asdf &>/dev/null && asdf where java &>/dev/null; then
    export JAVA_HOME="$(asdf where java)"
    export PATH="$JAVA_HOME/bin:$PATH"
fi


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
#
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


alias dps='docker ps --format "{{.Names}}\t{{.Ports}}\t{{.Image}}" | awk '\''BEGIN { printf "\033[1;34m%-25s\033[0m \033[1;32m%-40s\033[0m \033[1;36m%-20s\033[0m\n", "NAME", "PORTS", "IMAGE" } 
    { printf "\033[1;34m%-25s\033[0m \033[1;32m%-40s\033[0m \033[1;36m%-20s\033[0m\n", $1, $2, $3 }'\'''

export PATH="$HOME/bin/Sencha/Cmd:$PATH"

setopt pushd_ignore_dups pushd_silent


# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Tomcat/Java from asdf (if available)
command -v asdf &>/dev/null && asdf where tomcat &>/dev/null && export CATALINA_HOME=$(asdf where tomcat)
command -v asdf &>/dev/null && asdf where java &>/dev/null && export JAVA_HOME=$(asdf where java)

# Atuin shell history (if installed)
[[ -f "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"
command -v atuin &>/dev/null && eval "$(atuin init zsh)"
alias scaffold='bash $HOME/Desktop/cli/scaffold-module-java/scaffold.sh'


# Auto-install z if not present
[[ ! -f ~/z/z.sh ]] && git clone --depth 1 https://github.com/rupa/z.git ~/z

# Load z
. ~/z/z.sh

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
export AWS_PROFILE=sandbox-elitekaycy
alias minio-setup="mc alias set local http://localhost:9000 minioadmin minioadmin"


# Shutdown aliases
alias adios="sudo shutdown now"
alias aloha="sudo shutdown now"
alias sayanora="sudo shutdown now"
alias killmenow="sudo shutdown now"
alias shutdown="sudo shutdown now"
alias sss="sudo shutdown now"

# Restart aliases
alias reboot="sudo reboot"
alias rr="sudo reboot"

# Tmux aliases
alias tn='tmux new-session -s'       # tn work -> new session named "work"
alias ta='tmux attach-session -t'    # ta work -> attach to "work"
alias tl='tmux ls'                   # list sessions
alias tk='tmux kill-session -t'      # tk work -> kill "work"

# Load Angular CLI autocompletion (if installed)
command -v ng &>/dev/null && source <(ng completion script)

# PVIM Configuration
export PATH="$HOME/.local/bin:$PATH"
alias pvim='NVIM_APPNAME=pvim nvim'
alias pvi='NVIM_APPNAME=pvim nvim'
# END PVIM

# === Auto-install ZSH plugins ===
# zsh-autosuggestions (ghost text suggestions as you type)
znap source zsh-users/zsh-autosuggestions

# zsh-syntax-highlighting (colors for valid/invalid commands)
znap source zsh-users/zsh-syntax-highlighting
