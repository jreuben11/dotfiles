# set vi mode
# set -o vi # bash-style vi mode (redundant in zsh — bindkey -v below handles it)
bindkey -v
export KEYTIMEOUT=1

# Deduplicate PATH entries automatically
typeset -U path PATH

# History optimization
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicate entries
setopt HIST_REDUCE_BLANKS        # Remove extra blanks
setopt HIST_VERIFY               # Show command before executing from history
setopt SHARE_HISTORY             # Share history between sessions (implies APPEND_HISTORY)

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# cargo
. "$HOME/.cargo/env"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="powerlevel10k/powerlevel10k"

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
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

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
plugins=(
  colored-man-pages
  docker
  eza
#   fzf  # handled by source <(fzf --zsh)
  gcloud
  gh
  git
  golang
  history
  history-substring-search
  kubectl
  node
  npm
  podman
#   poetry
  python
  rust
  systemd
  tldr
#  tmux
  ubuntu
  web-search
  you-should-use
  zoxide
  zsh-autosuggestions
  zsh-completions
  zsh-interactive-cd
  zsh-navigation-tools
  zsh-syntax-highlighting
  )

source $ZSH/oh-my-zsh.sh

# Better completion behavior
setopt AUTO_MENU                 # Show completion menu on tab
setopt COMPLETE_IN_WORD          # Complete from both ends of word
setopt ALWAYS_TO_END             # Move cursor to end after completion
setopt AUTO_PARAM_SLASH          # Add slash after directory completion

# Directory navigation
setopt AUTO_PUSHD                # Make cd push old dir to dir stack
setopt PUSHD_IGNORE_DUPS         # Don't push duplicates
setopt PUSHD_SILENT              # Don't print dir stack after pushd/popd
alias d='dirs -v'                # Show directory stack

# Globbing
setopt EXTENDED_GLOB             # Extended globbing patterns
setopt NOCORRECTALL              # Only correct command names, not arguments

# Faster key bindings (vi mode enhancements)
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh



# CUDA - uses system default via symlink (/usr/local/cuda -> cuda-13.2)
export CUDA_HOME=/usr/local/cuda
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
export CUDA_SAMPLES=/usr/local/cuda-samples/Samples


# Deno
export DENO_INSTALL="/home/jreuben1/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"



# Wasmer
export WASMER_DIR="/home/jreuben1/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"

# FUNCTIONS
function commands() {
  awk '{a[$2]++}END{for(i in a){print a[i] " " i}}'
}
alias topten="history | commands | sort -rn | head"

function find_bios_info() {
  for d in system-manufacturer system-product-name bios-release-date bios-version bios-revision firmware-revision
  do
    echo "$d : "  $(sudo dmidecode -s $d)
  done
}

# Additional useful functions
mkcd() { mkdir -p "$@" && cd "$_"; }  # mkdir and cd into it
backup() { cp "$1"{,.backup}; }       # quick backup

# Extract any archive
extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)     echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# ALIASes
alias weather="curl wttr\.in"
alias bat="batcat"
alias inv='nvim $(fzf -m --preview="bat --color=always {}")' # open nvim with fzf selections

# HSTR configuration - add this to ~/.zshrc
alias hh=hstr                    # hh to be alias for hstr
setopt histignorespace           # skip cmds w/ leading space from history
export HSTR_CONFIG=hicolor       # get more colors
# bindkey -s "\C-r" "\C-a hstr -- \C-j"     # bind hstr to Ctrl-r (for Vi mode check doc)


export NVM_DIR="$HOME/.nvm"
# Lazy-load nvm — avoids ~200ms startup cost; initialises on first use of nvm/node/npm/npx
nvm() { unset -f nvm node npm npx; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"; nvm "$@"; }
node() { unset -f nvm node npm npx; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; node "$@"; }
npm()  { unset -f nvm node npm npx; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; npm "$@"; }
npx()  { unset -f nvm node npm npx; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; npx "$@"; }

# Android
# export ANDROID_HOME="/usr/lib/android-sdk/"
export ANDROID_HOME="${HOME}/Android/Sdk/"
export ANDROID_NDK_ROOT="${HOME}/Android/Sdk/ndk/" 
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
export ANDROID_NDK_HOME="${ANDROID_NDK_ROOT}27.0.11902837"
export PATH="${PATH}:$JAVA_HOME/bin"
export PATH="${PATH}:${ANDROID_HOME}tools/"
export PATH="${PATH}:${ANDROID_HOME}platform-tools/"

# Created by `pipx` on 2024-06-28 09:17:54
export PATH="$PATH:/home/jreuben1/.local/bin"

export EDITOR="nvim"

# starship
eval "$(starship init zsh)"
# zoxide
export _ZO_DATA_DIR="$HOME/.local/share/zoxide"
eval "$(zoxide init zsh)"
source <(fzf --zsh)

# yazi
alias ya='yazi.ya'
export YAZI_FILE_ONE="$HOME/.local/bin/yazi-file-mime"
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# golang
export PATH=$PATH:/usr/local/go/bin

# nvims switcher
alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
alias nvim-kick="NVIM_APPNAME=kickstart nvim"
alias nvim-chad="NVIM_APPNAME=NvChad nvim"
alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"

function nvims() {
  # items=("NvChad")
  items=("default" "kickstart" "LazyVim" "NvChad" "AstroNvim")
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=50% --layout=reverse --border --exit-0)
  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $config == "default" ]]; then
    config=""
  fi
  NVIM_APPNAME=$config nvim $@
}

# Kubectl krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# opam configuration
[[ ! -r /home/jreuben1/.opam/opam-init/init.zsh ]] || source /home/jreuben1/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null

# wezterm
alias wezterm='flatpak run org.wezfurlong.wezterm'

# zellij — auto-start in all terminals except Warp (which manages its own sessions)
if [[ -z "$ZELLIJ" && "$TERM_PROGRAM" != "WarpTerminal" && -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
  eval "$(zellij setup --generate-auto-start zsh)"
fi
function zr () { zellij run --name "$*" -- zsh -ic "$*";}
function zrf () { zellij run --name "$*" --floating -- zsh -ic "$*";}
function ze () { zellij edit "$*";}
function zef () { zellij edit --floating "$*";}

# eza
function ll() {
  local count=$(eza -1 "$@" 2>/dev/null | wc -l)
  if [[ $count -gt 35 ]]; then
    eza --long --grid --classify --icons --no-user --time-style=long-iso "$@"
  else
    eza --long --classify --icons --no-user --time-style=long-iso "$@"
  fi
}

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# pnpm
export PNPM_HOME="/home/jreuben1/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
# uv shell completions (cached — regenerates when uv binary is updated)
_uv_cache="$HOME/.cache/zsh/uv-completion.zsh"
if [[ ! -f "$_uv_cache" || "$(command -v uv)" -nt "$_uv_cache" ]]; then
    mkdir -p "${_uv_cache:h}"
    uv generate-shell-completion zsh >| "$_uv_cache"
    uvx --generate-shell-completion zsh >> "$_uv_cache"
fi
source "$_uv_cache"
unset _uv_cache

# uv python configuration
export UV_PYTHON="3.13"

# uv python aliases
alias python='uv run python'
alias pip='uv pip'
alias jlab='uv run --python ~/.venv/bin/python jupyter lab'

export PATH=$PATH:$HOME/go/bin

# ~/.fzf.zsh is empty; fzf key bindings handled by the fzf omz plugin above
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# bun completions
[ -s "/home/jreuben1/.bun/_bun" ] && source "/home/jreuben1/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# alias vlc='flatpak run org.videolan.VLC'  # Disabled - using native VLC for GPU acceleration

# LLVM 22
export PATH="/usr/lib/llvm-22/bin:$PATH"

# https://github.com/stanislc/zellij-claude-teams
if [[ -n "$ZELLIJ" ]]; then
    _shim="${XDG_DATA_HOME:-$HOME/.local/share}/zellij-tmux-shim/activate.sh"
    [[ -f "$_shim" ]] && source "$_shim"
    unset _shim
fi
claude-teams() {
    local dir="${1:-$PWD}"
    dir="$(realpath "$dir")"
    if [[ -n "$ZELLIJ" ]]; then
        zellij action new-tab --cwd "$dir" --layout claude-teams --name "claude:$(basename "$dir")"
    else
        cd "$dir" && zellij --layout claude-teams
    fi
}

# list tools
alias lsr="cargo install --list"
alias lsp="uv tool list"
alias lsj="pnpm list -g"
alias lsg="ls $HOME/go/bin"

[ -f ~/.secrets ] && source ~/.secrets
export PATH="$HOME/bin:$PATH"

# kubernetes
export KUBECONFIG=~/.kube/config:~/.kube/config-k3s:~/.kube/config-kubeadm
alias kctx='kubectl ctx'
alias kns='kubectl ns'
