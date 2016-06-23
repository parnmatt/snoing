#!/bin/echo This script should be sourced:

printf "snoing setup\n"
export PYTHONPATH=$PWD:$PWD/core:$PWD/packages:$PWD/versions:$PYTHONPATH

printf "%-50s" "Checking for git..."
if ! command -v git >/dev/null 2>&1; then
    printf "Not Installed\n"
    return
fi
printf "Installed\n"

printf "%-50s" "Checking if this is a git repository..."
if [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) != true ]]; then
    printf "no\n"
    return
fi
printf "yes\nAttempting update via git pull...\n"
git remote set-url origin git@github.com:snoplus/snoing.git
git pull
