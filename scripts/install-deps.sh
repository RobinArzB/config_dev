#!/bin/bash

while [[ "$1" != "" ]]; do
    case $1 in
        --debug ) set -x
                  ;;
    esac
    shift
done

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

echo "Installation completed!"
