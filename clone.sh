#!/bin/sh

if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s`
  ssh-add
fi

git clone --recursive git@github.com:Skeen/MetaThesis.git
