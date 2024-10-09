#!/bin/zsh

# the '(.)' is a glob qualifier for zsh only (maybe other shells idk)
cp .git*(.) ~/

git config --global core.editor "nvim"
git config --global core.excludesFile ~/.gitignore
git config --global commit.template ~/.gitmessage

