#!/bin/bash
set -e

# Get the absolute path to this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function ssh_agent {
    # Setup SSH agents
    if [ -z "$SSH_AUTH_SOCK" ] ; then
        # Start up the ssh-agent
        OUTPUT=$(ssh-agent -s)
        # Pick out the PID of the agent
        PID=$(echo "$OUTPUT" | grep "PID=" | sed "s/.*PID=\(.*\); .*/\1/g")
        echo $PID
        # Evaluate the configuration provided by ssh-agent
        eval $OUTPUT
        # Add / Unlock our key
        ssh-add
    fi
}

# Clone all repositories recursively
function clone {
    echo ""
    echo "Cloning MetaThesis"
    git clone git@github.com:Skeen/MetaThesis.git 1>/dev/null 2>/dev/null
}

# Pull in submodules and changes
function pull {
    echo ""
    echo "Moving to $1"
    cd $1

    echo -e "\tChecking out"
    git checkout $2 1>/dev/null 2>/dev/null
    echo -e "\tPulling"
    git pull 1>/dev/null 2>/dev/null
    # Clone recursively
    echo -e "\tInitializing submodules"
    git submodule update --init 1>/dev/null 2>/dev/null

    # Setup all submodules recursively
    GIT_FOLDERS=$(find . -mindepth 2 -name ".git")
    # Output them
    echo "Found repos (inside $PWD):"
    for REPO in $GIT_FOLDERS; do

        REPO_REAL=$(dirname "$REPO" | xargs realpath)
        echo -e "\t$REPO_REAL"
    done
    # Process them
    for REPO in $GIT_FOLDERS; do

        cd $1
        REPO_REAL=$(dirname "$REPO" | xargs realpath)
        pull "$REPO_REAL" "master"
    done
}

function kill_ssh_agent {
    kill $PID
}

trap kill_ssh_agent 2

case $1 in
    pull)
        ssh_agent
        pull
        kill_ssh_agent
        ;;
    *)
        ssh_agent
        clone
        pull "$DIR/MetaThesis" "master"
        kill_ssh_agent
esac
