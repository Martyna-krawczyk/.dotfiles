#!/usr/bin/env bash

# funcs
die() { echo "$1" >&2; exit "${2:-1}"; }

# check root
[[ -d .git ]] \
    || die "$0 must be run from the repository root directory"

# check os
os=$(uname) \
    || die "failed to get operating system"
[[ $os == Darwin ]] \
    || die "$os is not supported, missing implementation"

# check deps
deps=("curl" "brew")
for dep in "${deps[@]}" ; do
  hash "$dep" 2>/dev/null || missing+=("$dep")  
  done
    if [[ ${#missing[@]} -ne 0 ]]; then
        [[ ${#missing[@]} -gt 1 ]] && { s="s"; }
    die "missing dep${s}: ${missing[*]}"
fi

# setup cleanup
cleanup() {
  files=("./AWSCLIV2.pkg")
    [[ -f "$file" ]]
    rm -rf "$file" \
      || die "failed to clean up $file"
}
trap cleanup SIGTERM SIGINT EXIT

# setup .dotfiles
if ! [[ -d "$HOME/.dotfiles" ]]; then
  ln -s "$PWD" "$HOME/.dotfiles" \
    || die "failed to create symlink for .dotfiles"
fi

# setup .zshrc files
files=("zshenv" "zshrc")
for file in "${files[@]}"; do
  src="$PWD/zsh/$file"
  dest="$HOME/.$file"
  if ! [[ -L "$dest" ]]; then
    ln -s "$src" "$dest" \
      || die "failed to create symlink from $src to $dest"
  fi
done

# setup .gitconfig after deleting default
sudo rm -rf ~/.gitconfig \
  || die "failed to delete .gitconfig"
if ! [[ -d "$HOME/.gitconfig" ]]; then
  ln -s "$HOME/.dotfiles/config/gitconfig" "$PWD/.gitconfig" \
    || die "failed to create symlink for .gitconfig"
fi

# install aws
hash aws &>/dev/null || {
      file="AWSCLIV2.pkg"
      curl -sSLo "$file" "https://awscli.amazonaws.com/AWSCLIV2.pkg" \
        || die "failed to download $file"
      sudo installer -pkg AWSCLIV2.pkg -target / \
        || die "failed to install awscli"

  # set default region
  aws configure set region ap-southeast-2 \
    || die "failed to set the default aws region"
}


# install visual studio code 
hash code &>/dev/null || {
  brew install --cask visual-studio-code \
    || die "failed to install visual studio code"
}

# install brew packages
brew_packages=(
  "go" 
  "zsh" 
  "jq" 
  "lolcat" 
  "pyenv" 
  "cfn-lint" 
  "golangci-lint" 
  "k9s" 
  "kubernetes-cli" 
  "make" 
  "podman" 
  "yarn" 
  "dive"
)

for package in "${brew_packages[@]}"; do
  install_brew_package "$package"
done

# function to install brew packages
install_brew_package() {
  local package=$1
  hash "$package" &>/dev/null || {
    brew install "$package" \
      || die "failed to install $package"
  }
}

# switch default shell to zsh if installed
if hash zsh &>/dev/null; then
  chsh -s "$(which zsh)" \
    || die "failed to change default shell to zsh"
fi