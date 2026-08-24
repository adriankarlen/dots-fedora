# ~/.zshrc
# Ported from adriankarlen/dots for Fedora Asahi Remix (aarch64).
# macOS-only pieces from upstream are intentionally absent: homebrew shellenv,
# the Keychain-backed secret_load block, and `source gum-rose-pine`.

# Env vars and PATH live in ~/.zshenv so non-interactive login shells
# (the greetd-launched sway session) inherit them too.

# zinit setup
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# oh-my-posh
eval "$(oh-my-posh init zsh --config "$HOME/.config/ohmyposh/theme.toml")"

# zsh plugins
zinit light Aloxaf/fzf-tab
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# zsh snippets
zinit snippet OMZP::gh
zinit snippet OMZP::command-not-found

# load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# bindings
bindkey -e
bindkey '^y' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# history
HISTSIZE=5000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' popup-min-size 50 8
zstyle ':fzf-tab:*' fzf-flags --height=12

# opts
setopt auto_cd

# gum (Rose Pine GUM_* colours; also themes the sesh picker in tmux prefix+t)
source gum-rose-pine

# fzf
export FZF_DEFAULT_OPTS="
  --color=fg:#908caa,bg:#191724,hl:#ebbcba
  --color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba
  --color=border:#403d52,header:#31748f,gutter:#191724
  --color=spinner:#f6c177,info:#9ccfd8
  --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

# nvim nightly
function update-nvim() {
  local dir="/opt/nvim-linux-arm64"
  local tmp=$(mktemp -d)
  echo "Downloading nvim nightly..."
  curl -L --output-dir "$tmp" -O https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-arm64.tar.gz || {
    rm -rf "$tmp"; echo "download failed" >&2; return 1
  }
  tar xzf "$tmp/nvim-linux-arm64.tar.gz" -C "$tmp" || {
    rm -rf "$tmp"; echo "extract failed" >&2; return 1
  }
  sudo rm -rf "$dir"
  sudo mv "$tmp/nvim-linux-arm64" "$dir"
  rm -rf "$tmp"
  echo "nvim updated: $($dir/bin/nvim --version | head -1)"
}

# aliases
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias c="clear"
alias ...="cd ../.."
alias .3="cd ../../.."
alias .4="cd ../../../.."
alias .5="cd ../../../../.."
alias x="exit"

# eza aliases, active only once eza is installed
if command -v eza >/dev/null 2>&1; then
  alias l="eza -lh --icons=auto --color=always"                                         # long list
  alias la="eza -lha --icons=auto --color=always"                                       # long list all
  alias ls="eza --icons=auto --color=always"                                            # short list
  alias ll="eza -lha --icons=auto --sort=name --group-directories-first --color=always" # long list all
  alias ld="eza -lhD --icons=auto --color=always"                                       # long list dirs
  alias lt="eza --icons=auto --tree --color=always"                                     # list folder as tree
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons -a --group-directories-first --git --color=always $realpath'
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --icons -a --group-directories-first --git --color=always $realpath'
fi

# shell integrations
eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(fzf --zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init --cmd cd zsh)"
