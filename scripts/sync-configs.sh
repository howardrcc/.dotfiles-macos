#!/bin/bash
# Sync live configs back to dotfiles repo

DOTFILES=~/.dotfiles

cp ~/.config/aerospace/aerospace.toml "$DOTFILES/modules/home/aerospace/aerospace.toml"
echo "synced aerospace.toml"

cp ~/.config/karabiner/karabiner.json "$DOTFILES/karabiner/karabiner.json"
echo "synced karabiner.json"
