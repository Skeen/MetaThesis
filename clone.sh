#!/bin/sh

if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s`
  ssh-add
fi
# Clone all repositories recursively
git clone --recursive git@github.com:Skeen/MetaThesis.git
# Checkout branches
git submodule foreach -q --recursive \
  'git checkout $(git config -f $toplevel/.gitmodules submodule.$name.branch || echo master)'
