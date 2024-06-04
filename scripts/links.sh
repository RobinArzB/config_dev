#!/bin/bash

set -x

if [[ -d "$HOME/.config" ]]; then
    MOVE_CONFIG=true
fi

if [[ $MOVE_CONFIG ]]; then
    echo "Moving config"
    mv ~/.config ~/_tmp_config
fi

ln -sv ~/git/config_dev/xdg_config/ ~/.config

if [[ $MOVE_CONFIG ]]; then
    cp -r ~/_tmp_config/* ~/.config/
    rm -rf ~/_tmp_config
fi

# Home files
if [[ -f "~/.zshenv" ]]; then
    ln -vs ~/git/config_dev/home/.zshenv ~/.zshenv
fi
