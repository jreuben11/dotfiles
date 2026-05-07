# config.nu — shell settings, keybindings, aliases, and custom commands
# Ported from .zshrc

# === SHELL SETTINGS ===

$env.config.show_banner   = false
$env.config.edit_mode     = "vi"
$env.config.buffer_editor = "nvim"

$env.config.cursor_shape.vi_insert = "line"
$env.config.cursor_shape.vi_normal = "block"

$env.config.history.max_size     = 50000
$env.config.history.sync_on_enter = true
$env.config.history.file_format  = "sqlite"
$env.config.history.isolation    = false

# === KEYBINDINGS ===
# Ctrl+R (history search) is already bound by default in Nu

$env.config.keybindings = [
    { name: ctrl_p  modifier: control  keycode: char_p  mode: [vi_insert emacs]  event: { send: Up } }
    { name: ctrl_n  modifier: control  keycode: char_n  mode: [vi_insert emacs]  event: { send: Down } }
    { name: ctrl_a  modifier: control  keycode: char_a  mode: [vi_insert emacs]  event: { edit: MoveToLineStart } }
    { name: ctrl_e  modifier: control  keycode: char_e  mode: [vi_insert emacs]  event: { edit: MoveToLineEnd } }
]

# === INTEGRATIONS ===

source ~/.config/nushell/starship.nu
source ~/.config/nushell/zoxide.nu
source ~/.config/nushell/fnm.nu
source ~/.config/nushell/completions/uv.nu
source ~/.config/nushell/completions/uvx.nu

source ~/.secrets.nu

# === ZELLIJ AUTO-START ===

if ($env.ZELLIJ? | is-empty) and (($env.TERM_PROGRAM? | default "") != "WarpTerminal") {
    ^zellij attach -c
}

# === ALIASES ===

alias weather    = ^curl wttr.in
alias bat        = batcat
alias hh         = hstr
alias wezterm    = ^flatpak run org.wezfurlong.wezterm
alias lsr        = ^cargo install --list
alias lsp        = ^uv tool list
alias lsj        = ^pnpm list -g
alias python     = ^uv run python
alias pip        = ^uv pip

# === CUSTOM COMMANDS ===

# mkdir and cd into it
def --env mkcd [dir: string] {
    mkdir $dir
    cd $dir
}

# quick backup copy
def backup [file: string] {
    cp $file $"($file).backup"
}

# extract any archive by extension
def extract [file: string] {
    if not ($file | path exists) {
        error make { msg: $"'($file)' is not a valid file" }
    }
    if ($file | str ends-with ".tar.bz2") or ($file | str ends-with ".tbz2") {
        ^tar xjf $file
    } else if ($file | str ends-with ".tar.gz") or ($file | str ends-with ".tgz") {
        ^tar xzf $file
    } else {
        let ext = ($file | path parse | get extension)
        match $ext {
            "bz2" => { ^bunzip2 $file }
            "rar" => { ^unrar e $file }
            "gz"  => { ^gunzip $file }
            "tar" => { ^tar xf $file }
            "zip" => { ^unzip $file }
            "Z"   => { ^uncompress $file }
            "7z"  => { ^7z x $file }
            _     => { error make { msg: $"'($file)' cannot be extracted" } }
        }
    }
}

# yazi wrapper — propagates cwd change back to shell on exit
def --env yy [...args: string] {
    let tmp = (^mktemp -t "yazi-cwd.XXXXXX" | str trim)
    ^yazi ...$args --cwd-file $tmp
    let cwd = (open $tmp | str trim)
    if ($cwd | is-not-empty) and $cwd != $env.PWD {
        cd $cwd
    }
    rm -f $tmp
}

# fzf-based neovim config switcher
def nvims [...args: string] {
    let items = ["default" "kickstart" "LazyVim" "NvChad" "AstroNvim"]
    let selection = ($items | str join "\n" | ^fzf --prompt=" Neovim Config  " --height=50% --layout=reverse --border --exit-0 | str trim)
    if ($selection | is-empty) {
        print "Nothing selected"
        return
    }
    let appname = if $selection == "default" { "" } else { $selection }
    with-env { NVIM_APPNAME: $appname } { ^nvim ...$args }
}

# neovim config aliases
def nvim-lazy  [...args: string] { with-env { NVIM_APPNAME: "LazyVim"   } { ^nvim ...$args } }
def nvim-kick  [...args: string] { with-env { NVIM_APPNAME: "kickstart"  } { ^nvim ...$args } }
def nvim-chad  [...args: string] { with-env { NVIM_APPNAME: "NvChad"     } { ^nvim ...$args } }
def nvim-astro [...args: string] { with-env { NVIM_APPNAME: "AstroNvim"  } { ^nvim ...$args } }

# open file(s) in nvim selected via fzf
def inv [] {
    let files = (^fzf -m --preview "batcat --color=always {}" | lines)
    if ($files | is-not-empty) {
        ^nvim ...$files
    }
}

# eza ls — auto grid layout for large dirs
def ll [...args: string] {
    let count = (^eza -1 ...$args | lines | length)
    if $count > 35 {
        ^eza --long --grid --classify --icons --no-user --time-style=long-iso ...$args
    } else {
        ^eza --long --classify --icons --no-user --time-style=long-iso ...$args
    }
}

# top 10 most-used commands from history
def topten [] {
    history
    | get command
    | each { |line|
        let words = ($line | split words)
        if ($words | is-not-empty) { $words | first } else { null }
    }
    | compact
    | uniq -c
    | sort-by count -r
    | first 10
}

# list installed go binaries
def lsg [] {
    ls $"($env.HOME)/go/bin"
}

# jupyter lab via uv venv
def jlab [] {
    ^uv run --python $"($env.HOME)/.venv/bin/python" jupyter lab
}

# DMI/BIOS hardware info
def find_bios_info [] {
    ["system-manufacturer" "system-product-name" "bios-release-date" "bios-version" "bios-revision" "firmware-revision"]
    | each { |d| { key: $d, value: (^sudo dmidecode -s $d | str trim) } }
}

# zellij helpers
def zr  [...args: string] { let c = ($args | str join " "); ^zellij run --name $c -- zsh -ic $c }
def zrf [...args: string] { let c = ($args | str join " "); ^zellij run --name $c --floating -- zsh -ic $c }
def ze  [file: string]    { ^zellij edit $file }
def zef [file: string]    { ^zellij edit --floating $file }

# open new zellij tab with claude-teams layout
def --env claude-teams [dir?: string] {
    let target = if $dir != null { $dir | path expand } else { $env.PWD }
    if ($env.ZELLIJ? | is-not-empty) {
        ^zellij action new-tab --cwd $target --layout claude-teams --name $"claude:(($target | path basename))"
    } else {
        cd $target
        ^zellij --layout claude-teams
    }
}

# SDKman — bash-only; wraps `sdk` commands via bash subshell
def sdk [...args: string] {
    bash -c $"source ($env.SDKMAN_DIR)/bin/sdkman-init.sh && sdk ($args | str join ' ')"
}
