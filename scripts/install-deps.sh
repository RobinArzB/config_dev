#!/bin/bash

set -e
set -x

INSTALL_GUI=true
NEOVIM_VERSION="stable"

if [ "$1" == "--no-gui" ]; then
    INSTALL_GUI=false
fi

if [ ! -z "$1" ]; then
    if [ "$1" == "stable" ]; then
        NEOVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
    else
        NEOVIM_VERSION="$1"
    fi
fi

echo "Creating necessary directories..."
mkdir -p ~/build
mkdir -p ~/git

echo "Updating package lists..."
sudo apt update

echo "Installing required packages..."
sudo apt-get install -y \
    make cmake git \
    gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip \
    make build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python3-pip

echo "Checking if Neovim is already installed..."
if ! [ -d $HOME/build/neovim ]; then
    echo "Cloning Neovim..."
    git clone https://github.com/neovim/neovim ~/build/neovim
    cd ~/build/neovim/
    echo "Checking out version $NEOVIM_VERSION..."
    git checkout $NEOVIM_VERSION
    echo "Building Neovim..."
    make -j2
    echo "Installing Neovim..."
    sudo make install -s
else
    echo "Neovim is already installed."
    cd ~/build/neovim/
    CURRENT_VERSION=$(git rev-parse --abbrev-ref HEAD)
    if [ "$CURRENT_VERSION" != "$NEOVIM_VERSION" ]; then
        echo "Switching to version $NEOVIM_VERSION..."
        git fetch origin
        git checkout $NEOVIM_VERSION
        echo "Building Neovim..."
        make clean
        make -j2
        echo "Installing Neovim..."
        sudo make install -s
    else
        echo "Neovim is already at the desired version $NEOVIM_VERSION."
    fi
fi

echo "Switching default shell to Zsh..."
sudo apt-get install zsh -y
chsh -s $(which zsh)

echo "Installing Antigen (zsh plugins manager)..."
ANTIGEN_DIR="./xdg_config/antigen"
mkdir -p "$ANTIGEN_DIR"
curl -L git.io/antigen > "$ANTIGEN_DIR/antigen.zsh"
echo "Antigen installed in $ANTIGEN_DIR/antigen.zsh"

echo "Setting up Mise-en-Place..."
if ! command -v ~/.local/bin/mise &>/dev/null; then
    echo "Mise en Place is not installed. Installing now..."
    curl https://mise.run | sh
else
    echo "Mise en Place is already installed."

echo "Checking if Rust is installed..."
if ! [ -x "$(command -v cargo)" ]; then
  echo "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
else
  echo "Rust is already installed."
fi

echo "Checking if Starship is installed..."
if ! command -v starship &>/dev/null; then
  echo "Installing Starship prompt..."
  curl -sS https://starship.rs/install.sh | sh
else
  echo "Starship is already installed."
fi

echo "Installing rust cli apps..."
cargo install atuin git-delta

echo "Installing additional CLI tools..."
sudo apt install -y \
    python3-venv \
    xclip dnsutils \
    btop pass tree \
    direnv pwgen i3 i3status

echo "Installing 'uv' - Python package installer..."
if ! command -v uv &> /dev/null ; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "uv is already installed."
fi

if [ "$INSTALL_GUI" = true ]; then
    echo "Checking for WezTerm..."
    # WezTerm
    if ! command -v wezterm &> /dev/null ; then
        echo "Installing WezTerm..."
        curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
        echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
        sudo apt update && sudo apt install -y wezterm
    else
        echo "WezTerm is already installed."
    fi

    echo "Installing desktop applications..."
    sudo apt install -y \
        firefox \
        flameshot

    echo "Checking if Brave Browser is installed..."
    # Brave Browser
    if ! command -v brave-browser &> /dev/null ; then
        echo "Installing Brave Browser..."
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        sudo apt update && sudo apt install -y brave-browser
    else
        echo "Brave Browser is already installed."
    fi
else
    echo "Skipping GUI applications installation."
fi

echo "Installation completed!"
