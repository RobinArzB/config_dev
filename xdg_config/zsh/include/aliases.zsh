#!/bin/zsh

alias s='source ~/.config/zsh/.zshrc'
alias ll='ls -al'
alias la='ls -A'
alias l='ls -CF'

alias h="history|grep "
alias agi='sudo apt-get install '
alias agu='sudo apt-get update && sudo apt-get upgrade'
alias diskspace="du -S | sort -n -r |more"
alias folders="find . -maxdepth 1 -type d -print | xargs du -sk | sort -rn"