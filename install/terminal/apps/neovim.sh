#!/bin/bash

cd /tmp
wget -O nvim.tar.gz "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz"
tar -xf nvim.tar.gz
sudo install nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
sudo cp -R nvim-linux-x86_64/lib /usr/local/
sudo cp -R nvim-linux-x86_64/share /usr/local/
rm -rf nvim-linux-x86_64 nvim.tar.gz
cd -

# Install luarocks and tree-sitter-cli to resolve lazyvim :checkhealth warnings
sudo apt install -y luarocks tree-sitter-cli

# Only attempt to set configuration if Neovim has never been run
if [ ! -d "$HOME/.config/nvim" ]; then
  # Use LazyVim
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  # Remove the .git folder, so you can add it to your own repo later
  rm -rf ~/.config/nvim/.git

  # Make everything match the terminal transparency
  mkdir -p "$HOME/.config/nvim/plugin/after"
  cp "$HAWKUP_DIR/configs/nvim/transparency.lua" "$HOME/.config/nvim/plugin/after/"

  # Default to Tokyo Night theme
  mkdir -p "$HOME/.config/nvim/lua/plugins"
  cp "$HAWKUP_DIR/configs/nvim/theme.lua" "$HOME/.config/nvim/lua/plugins/theme.lua"

  # Turn off animated scrolling
  cp "$HAWKUP_DIR/configs/nvim/snacks-animated-scrolling-off.lua" "$HOME/.config/nvim/lua/plugins/"

  # Turn off relative line numbers
  echo "vim.opt.relativenumber = false" >>"$HOME/.config/nvim/lua/config/options.lua"

  # Ensure editor.neo-tree is used by default
  cp "$HAWKUP_DIR/configs/nvim/lazyvim.json" "$HOME/.config/nvim/"
fi
