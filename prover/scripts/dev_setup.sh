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

RESOURCES_DIR="$HOME/.local/share/aptos-prover-service"
mkdir -p $RESOURCES_DIR/setup_2024_05

# Get prover and verification key from official trusted setup repo
curl --location -o "$RESOURCES_DIR/setup_2024_05/prover_key.zkey" https://github.com/aptos-labs/aptos-keyless-trusted-setup-contributions-may-2024/raw/main/contributions/main_39f9c44b4342ed5e6941fae36cf6c87c52b1e17f_final.zkey
curl --location -o "$RESOURCES_DIR/setup_2024_05/verification_key.json" https://github.com/aptos-labs/aptos-keyless-trusted-setup-contributions-may-2024/raw/main/verification_key_39f9c44b4342ed5e6941fae36cf6c87c52b1e17f.json

# Get witness generation binaries (c++/asm binary version)
curl --location -o "$RESOURCES_DIR/setup_2024_05/main_c" https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_c_cpp/main_c
curl --location -o "$RESOURCES_DIR/setup_2024_05/main_c.dat" https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_c_cpp/main_c.dat

# Get witness generation binaries
curl --location -o "$RESOURCES_DIR/setup_2024_05/generate_witness.js" https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_js/generate_witness.js
curl --location -o "$RESOURCES_DIR/setup_2024_05/main.wasm" https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_js/main.wasm
curl --location -o "$RESOURCES_DIR/setup_2024_05/witness_calculator.js" https://github.com/aptos-labs/devnet-groth16-keys/raw/master/main_js/witness_calculator.js

# Get extra circuit config
curl --location -o "$RESOURCES_DIR/setup_2024_05/circuit_config.yml" https://raw.githubusercontent.com/aptos-labs/aptos-keyless-trusted-setup-contributions-may-2024/0f2ca4730147c5d4123b9c32a0cf0bd800f36b38/circuit_config.yml

# TODO: replace with the next realworld setup data once it is available.
#  Currently using the initial setup data as a placeholder. NOTE: it does not work with the current prove request scheme.
#mkdir -p $RESOURCES_DIR/setup_2024_02
#curl --location -o "$RESOURCES_DIR/setup_2024_02/prover_key.zkey" https://github.com/aptos-labs/aptos-keyless-trusted-setup-contributions/raw/0b3542aeb1526e16dbc14c5c0ba0bf98ffe73bf6/contributions/main_final.zkey
#curl --location -o "$RESOURCES_DIR/setup_2024_02/verification_key.json" https://raw.githubusercontent.com/aptos-labs/aptos-keyless-trusted-setup-contributions/0b3542aeb1526e16dbc14c5c0ba0bf98ffe73bf6/verification_key.json
#curl --location -o "$RESOURCES_DIR/setup_2024_02/main_c" https://github.com/aptos-labs/devnet-groth16-keys/raw/42deb24b17f6f0370a6fcf6db9e0696a5bdf767a/main_c_cpp/main_c
#curl --location -o "$RESOURCES_DIR/setup_2024_02/main_c.dat" https://github.com/aptos-labs/devnet-groth16-keys/raw/42deb24b17f6f0370a6fcf6db9e0696a5bdf767a/main_c_cpp/main_c.dat
#curl --location -o "$RESOURCES_DIR/setup_2024_02/generate_witness.js" https://raw.githubusercontent.com/aptos-labs/devnet-groth16-keys/42deb24b17f6f0370a6fcf6db9e0696a5bdf767a/main_js/generate_witness.js
#curl --location -o "$RESOURCES_DIR/setup_2024_02/main.wasm" https://github.com/aptos-labs/devnet-groth16-keys/raw/42deb24b17f6f0370a6fcf6db9e0696a5bdf767a/main_js/main.wasm
#curl --location -o "$RESOURCES_DIR/setup_2024_02/witness_calculator.js" https://github.com/aptos-labs/devnet-groth16-keys/raw/42deb24b17f6f0370a6fcf6db9e0696a5bdf767a/main_js/witness_calculator.js
#curl --location -o "$RESOURCES_DIR/setup_2024_02/circuit_config.yml" https://github.com/aptos-labs/devnet-groth16-keys/raw/42deb24b17f6f0370a6fcf6db9e0696a5bdf767a/circuit_config.yml

chmod -R u+rwx $RESOURCES_DIR



