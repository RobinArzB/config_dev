# Basic functions
alias gs='git status'
alias gpull='git pull'
alias gout='git checkout'
alias gpush='git push'
alias gd='git diff'
alias gpr='git pull --rebase'

# Adding helpers
alias gadd='git add .'
alias gca='git add . && git commit -av'

# Logging helpers
alias gls='git log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate'
alias gll='git log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat'
alias gdate='git log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=relative'
alias gdatelong='git log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=short'

alias gfind='git ls-files | grep -i'

# Switching contexts
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit -m "[WIP]: $(date)"'

# Oops savers
alias gundo='git reset HEAD~'


gnrebase() {
    echo "==> Checking out main..."
    git checkout main
    echo ""
    echo "==> Updating main..."
    git pull
    echo ""
    echo "==> Checking back to original branch"
    git checkout -
    echo ""
    echo "==> Rebasing main onto $(git rev-parse --abbrev-ref HEAD)"
    git rebase main $(git rev-parse --abbrev-ref HEAD)
    echo ""
}

gpo() {
    git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD)
}