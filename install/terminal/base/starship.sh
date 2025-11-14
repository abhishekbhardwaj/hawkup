#!/bin/bash

curl -sS https://starship.rs/install.sh | sh -s -- -y

cp -r "$HAWKUP_DIR/configs/starship.toml" "$HOME/.config/starship.toml"
