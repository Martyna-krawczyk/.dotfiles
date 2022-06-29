#!/usr/bin/env bash

# funcs.
die() { echo "$1" >&2; exit "${2:-1}"; }

# check root.
[[ -d .git ]] \
    || die "$0 must be run from the repository root directory"

# setup .dotfiles.
if ! [[ -d "$HOME/.dotfiles" ]]; then
  ln -s "$PWD" "$HOME/.dotfiles" \
    || die "failed to create symlink for .dotfiles"
fi

# setup .zshrc files.
files=("zshenv" "zshrc")
for file in "${files[@]}"; do
  src="$PWD/zsh/$file"
  dest="$HOME/.$file"
  if ! [[ -L "$dest" ]]; then
    ln -s "$src" "$dest" \
      || die "failed to create symlink from $src to $dest"
  fi
done

# setup .gitconfig.
# TODO-check if .gitconfig already exists and if it does, delete it
if ! [[ -d "$HOME/.gitconfig" ]]; then
  ln -s "$HOME/.dotfiles/config/gitconfig" "$PWD/.gitconfig" \
    || die "failed to create symlink for .gitconfig"
fi

# install tools
# brew, tree kubectl docker jq
# ansible