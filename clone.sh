#!/bin/sh

# Get the absolute path to this script
SCRIPT_PATH=$(readlink -e $0)

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
# Clone all repositories recursively
git clone --recursive git@github.com:Skeen/MetaThesis.git
# Setup all submodules recursively
GIT_FOLDERS=$(find . -name ".git" | xargs dirname | xargs realpath)
for repo in $GIT_FOLDERS; do
    cd $repo && \
        git submodule init &&
        git submodule update

    cd $repo && \
        git submodule foreach -q --recursive \
            'git checkout $(git config -f $toplevel/.gitmodules submodule.$name.branch || echo master)'
done

# Kill our spawned ssh-agent
kill $PID
# Self-destruct
#rm -- "$SCRIPT_PATH"
