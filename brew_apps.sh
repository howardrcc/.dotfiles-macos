brew neovim
brew rcm
brew install --HEAD utf8proc
brew install luarocks
brew install lua
brew install alacritty
brew install --cask kitty
brew install font-meslo-lg-nerd-font
brew install powerlevel10k
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting
brew install zoxide #smarter cd
brew install eza    #smarter ls

#some brews in sketchybar/helpers
# Packages
brew install switchaudio-osx
brew install nowplaying-cli

brew tap FelixKratz/formulae
brew install sketchybar

# Fonts
brew install --cask sf-symbols
brew install --cask homebrew/cask-fonts/font-sf-mono
brew install --cask homebrew/cask-fonts/font-sf-pro
brew install --cask visual-studio-code
brew install --cask ghostty
#none-brew

curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.5/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf

# SbarLua
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)

#tailscale
curl -L https://pkgs.tailscale.com/stable/Tailscale-latest-macos.pkg -o $HOME/Downloads/Tailscale-latest-macos.pkg
