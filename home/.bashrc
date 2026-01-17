# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# -----------------------------------------------------------------------------
# History Configuration
# -----------------------------------------------------------------------------
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend

# -----------------------------------------------------------------------------
# Shell Options
# -----------------------------------------------------------------------------
# Check window size after each command
shopt -s checkwinsize

# Enable ** glob pattern
shopt -s globstar 2>/dev/null

# -----------------------------------------------------------------------------
# Prompt Configuration
# -----------------------------------------------------------------------------
# Set a fancy prompt (non-color, unless we know we want color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt

# If this is an xterm, set the title
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# -----------------------------------------------------------------------------
# .NET Configuration
# -----------------------------------------------------------------------------
export DOTNET_ROOT=/usr/share/dotnet
export PATH="$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# .NET CLI tab completion
if command -v dotnet &> /dev/null; then
    _dotnet_bash_complete()
    {
        local cur="${COMP_WORDS[COMP_CWORD]}" IFS=$'\n'
        local candidates
        read -d '' -ra candidates < <(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)
        read -d '' -ra COMPREPLY < <(compgen -W "${candidates[*]:-}" -- "$cur")
    }
    complete -f -F _dotnet_bash_complete dotnet
fi

# -----------------------------------------------------------------------------
# Local customizations
# -----------------------------------------------------------------------------
# Source local bashrc if it exists (for user customizations)
if [ -f "$HOME/.bashrc.local" ]; then
    . "$HOME/.bashrc.local"
fi
