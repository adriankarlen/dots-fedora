# dots fedora

Dotfiles for the Fedora machine, managed with GNU Stow (see `./dot`).
Mirrors the layout of [`adriankarlen/dots`](https://github.com/adriankarlen/dots)
but stays separate because Fedora-only tweaks live here.

## Submodules

- `home/.config/nvim` → [`adriankarlen/nvim`](https://github.com/adriankarlen/nvim)

  Shared with the macOS dotfiles to avoid maintaining two configs. After
  a fresh clone, init it with:

  ```sh
  git submodule update --init --recursive
  ```

## Bootstrap on a new machine

```sh
./dot link                  # install `dot` itself into ~/.local/bin
./dot stow                  # create/refresh symlinks under $HOME
git submodule update --init # populate home/.config/nvim
./scripts/install-pi-packages.sh
```
