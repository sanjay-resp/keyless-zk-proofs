#!/bin/bash

set -e
set -x

PACKAGE_MANAGER=
if [[ "$(uname)" == "Linux" ]]; then
  if command -v yum &>/dev/null; then
    PACKAGE_MANAGER="yum"
  elif command -v apt-get &>/dev/null; then
    PACKAGE_MANAGER="apt-get"
  elif command -v pacman &>/dev/null; then
    PACKAGE_MANAGER="pacman"
  elif command -v apk &>/dev/null; then
    PACKAGE_MANAGER="apk"
  elif command -v dnf &>/dev/null; then
    echo "WARNING: dnf package manager support is experimental"
    PACKAGE_MANAGER="dnf"
  else
    echo "Unable to find supported package manager (yum, apt-get, dnf, or pacman). Abort"
    exit 1
  fi
elif [[ "$(uname)" == "Darwin" ]]; then
  if command -v brew &>/dev/null; then
    PACKAGE_MANAGER="brew"
  else
    echo "Missing package manager Homebrew (https://brew.sh/). Abort"
    exit 1
  fi
else
  echo "Unknown OS. Abort."
  exit 1
fi



function install_rustup {

  # Install Rust
    echo "Installing Rust......"
  VERSION="$(rustup --version || true)"
  if [ -n "$VERSION" ]; then
      echo "Rustup is already installed, version: $VERSION"
  else
    curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable
    if [[ -n "${CARGO_HOME}" ]]; then
      PATH="${CARGO_HOME}/bin:${PATH}"
    else
      PATH="${HOME}/.cargo/bin:${PATH}"
    fi
  fi
}

if [[ $PACKAGE_MANAGER == "apt-get" ]]; then 
  sudo apt-get update
  sudo apt-get install -y pkg-config gcc clang cmake make libyaml-dev nasm libgmp-dev libomp-dev libssl-dev
elif [[ $PACKAGE_MANAGER == "brew" ]]; then 
  brew install cmake libyaml nasm gmp
else
  echo "Unsupported platform. Currently this script only supports Ubuntu, Debian and macOS."
  exit 1
fi

install_rustup 

git submodule update --init --recursive

SCRIPT_DIR="$(pwd)"
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$SCRIPT_DIR/rust-rapidsnark/rapidsnark/package/lib
