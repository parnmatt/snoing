#!/bin/echo This script should be sourced:

printf "Setup snoing\n"

function cleanup {
    unset internet snoing_upstream_url current_branch
    unset cleanup internet_connection
}

function internet_connection {
    number_of_tries=${1:-3}

    if [[ -z $internet ]]; then
        printf "%-50s" "Checking for internet, $number_of_tries passes..."
        internet=$(ping -c$number_of_tries 8.8.8.8 >/dev/null 2>&1; printf $?)
        [[ $internet == 0 ]] && printf "found\n" || printf "not found\n"
    fi
    return $internet
}

export PYTHONPATH=$PWD:$PWD/core:$PWD/packages:$PWD/versions:$PYTHONPATH

printf "%-50s" "Checking for git..."
if ! command -v git >/dev/null 2>&1; then
    printf "Not Installed\n"
    cleanup
    return
fi
printf "Installed\n"

printf "%-50s" "Checking if this is a git repository..."
if [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) != true ]]; then
    printf "no\n"
    cleanup
    return
fi
printf "yes\n"

snoing_upstream_url="git@github.com:snoplus/snoing.git"
if [[ $(git config remote.origin.url) != $snoing_upstream_url ]]; then
    printf "Using custom snoing\n"
    printf "Checking upstream\n"
    if ! git config remote.upstream.url >/dev/null; then
        git remote add -t master upstream $snoing_upstream_url
    else
        git remote set-url upstream $snoing_upstream_url
    fi

    if ! internet_connection; then
        cleanup
        return
    fi
    git fetch upstream
else
    printf "Using upstream snoing\n"
fi

current_branch=$(git symbolic-ref HEAD 2>/dev/null)
current_branch=${current_branch#refs/heads/}
if ! git config branch.$current_branch.merge >/dev/null 2>&1; then
    printf "No tracked branch\n"
    cleanup
    return
fi

if ! internet_connection; then
    cleanup
    return
fi
printf "Attempting update via git pull...\n"
git pull

cleanup
return
