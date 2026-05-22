#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
output_style=$(echo "$input" | jq -r '.output_style.name // ""')

# Extract context usage from pre-calculated JSON fields
context_percent=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
tokens_used=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
tokens_total=$(echo "$input" | jq -r '.context_window.context_window_size // 0')

# Format token counts as k (e.g. 94000 -> 94k, 200000 -> 200k)
if [ -n "$tokens_used" ] && [ "$tokens_used" -gt 0 ] 2>/dev/null; then
    tokens_used_fmt=$(awk "BEGIN {printf \"%.0fk\", $tokens_used/1000}")
else
    tokens_used_fmt="0k"
fi
if [ -n "$tokens_total" ] && [ "$tokens_total" -gt 0 ] 2>/dev/null; then
    tokens_total_fmt=$(awk "BEGIN {printf \"%.0fk\", $tokens_total/1000}")
else
    tokens_total_fmt="?"
fi

# Round percentage to integer if present
if [ -n "$context_percent" ]; then
    context_percent=$(awk "BEGIN {printf \"%.0f\", $context_percent}")
fi

# Colors matching Starship theme
c_reset="\033[0m"
c_blue_bg="\033[48;2;118;159;240m"    # #769ff0
c_dark_bg="\033[48;2;57;66;96m"       # #394260
c_darker_bg="\033[48;2;33;39;54m"     # #212736
c_white_fg="\033[38;2;227;229;229m"   # #e3e5e5
c_blue_fg="\033[38;2;118;159;240m"    # #769ff0
c_purple_fg="\033[38;2;147;51;234m"   # Purple for high context usage
c_green_fg="\033[38;2;106;192;120m"   # Green for low context usage
c_yellow_fg="\033[38;2;255;213;79m"   # Yellow for medium context usage

# Powerline separator
sep=""

# Get directory (basename and abbreviate home)
dir="${cwd/#$HOME/~}"
# Truncate long paths
if [ ${#dir} -gt 40 ]; then
    dir="...${dir: -37}"
fi

# Get git branch if in a git repo (skip locks for performance)
git_branch=""
if git -C "$cwd" --no-optional-locks rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null || echo "detached")
    if [ -n "$branch" ]; then
        git_branch=" ${branch}"
    fi
fi

# Check for language version files and get versions
lang_info=""

# Check for Node.js
if [ -f "$cwd/package.json" ] && command -v node >/dev/null 2>&1; then
    node_version=$(node --version 2>/dev/null | sed 's/v//')
    if [ -n "$node_version" ]; then
        lang_info="${lang_info} ${node_version}"
    fi
fi

# Check for Rust
if [ -f "$cwd/Cargo.toml" ] && command -v rustc >/dev/null 2>&1; then
    rust_version=$(rustc --version 2>/dev/null | awk '{print $2}')
    if [ -n "$rust_version" ]; then
        lang_info="${lang_info} ${rust_version}"
    fi
fi

# Check for Go
if [ -f "$cwd/go.mod" ] && command -v go >/dev/null 2>&1; then
    go_version=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
    if [ -n "$go_version" ]; then
        lang_info="${lang_info} ${go_version}"
    fi
fi

# Build the status line
status_line=""

# Directory segment
status_line+=$(printf "${c_blue_bg}${c_white_fg}  ${dir} ${c_reset}")

# Git segment (if exists)
if [ -n "$git_branch" ]; then
    status_line+=$(printf "${c_dark_bg}${c_blue_fg}${sep}${c_reset}")
    status_line+=$(printf "${c_dark_bg}${c_blue_fg}${git_branch} ${c_reset}")
fi

# Language info segment (if exists)
if [ -n "$lang_info" ]; then
    if [ -n "$git_branch" ]; then
        status_line+=$(printf "${c_darker_bg}${c_dark_bg}${sep}${c_reset}")
    else
        status_line+=$(printf "${c_darker_bg}${c_blue_bg}${sep}${c_reset}")
    fi
    status_line+=$(printf "${c_darker_bg}${c_blue_fg}${lang_info} ${c_reset}")
fi

# Model info (append at end)
if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
    model_text="${model} [${output_style}]"
else
    model_text="${model}"
fi

# Close powerline
if [ -n "$lang_info" ]; then
    status_line+=$(printf "${c_darker_bg}${c_reset}${sep}")
elif [ -n "$git_branch" ]; then
    status_line+=$(printf "${c_dark_bg}${c_reset}${sep}")
else
    status_line+=$(printf "${c_blue_bg}${c_reset}${sep}")
fi

# Add context usage with color based on percentage (only when data is available)
if [ -n "$context_percent" ]; then
    # Choose color based on usage level
    if [ "$context_percent" -ge 75 ]; then
        context_color="${c_purple_fg}"  # High usage (75%+)
    elif [ "$context_percent" -ge 50 ]; then
        context_color="${c_yellow_fg}"  # Medium usage (50-74%)
    else
        context_color="${c_green_fg}"   # Low usage (<50%)
    fi

    # Format: ⛁ 47% (94k/200k)
    status_line+=$(printf " ${context_color}⛁ ${context_percent}%% (${tokens_used_fmt}/${tokens_total_fmt})${c_reset}")
fi

# Add model info at the end
status_line+=$(printf " ${model_text}")

# Output the status line
printf "%b\n" "$status_line"
