#!/usr/bin/env bash

dotfiles=${dotfiles:-${HOME}/.dotfiles}

echo ""
echo -e "${text_green}Starting setup...${text_normal}"
echo ""

if ! command -v "rcup" &> /dev/null; then
  echo -e "${text_red}RCM is not installed.  Please install it and try again.${text_normal}"
  exit 1
fi

rcup -f -K -d "${dotfiles}" rcrc

echo -e "${text_green}Done!  Edit the ~/.rcrc as needed then run 'rcup'${text_normal}"
echo ""

unset dotfiles
#unset dotfiles_private
