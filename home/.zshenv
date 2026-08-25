# ~/.zshenv
# Read by every zsh invocation (interactive, login and script alike).
# Env vars and PATH live here rather than in .zshrc so that non-interactive
# login shells get them too -- greetd starts the sway session as
# `$SHELL -l -c sway`, which never sources .zshrc.

# env vars
export XDG_CONFIG_HOME="$HOME/.config"
export EZA_CONFIG_DIR="$HOME/.config/eza"
export EDITOR=nvim

# ripgrep
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

# keep PATH free of duplicates across nested shells
typeset -U path PATH

# PATH
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux-arm64/bin"
export PATH="$PATH:$HOME/go/bin"
export PATH="$HOME/.local/share/npm-global/bin:$PATH"
. "$HOME/.cargo/env"
