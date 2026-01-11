#! /bin/bash

set -e

omarchy-show-logo

echo "Uninstalling theme hook.."

rm -rf /tmp/theme-hook/
rm -rf $HOME/.local/share/omarchy/bin/thctl
rm -rf $HOME/.config/omarchy/hooks/theme-set.d/
rm -rf $HOME/.config/omarchy/hooks/theme-set

echo "Attempting to unapply theme hook.."

# Remove Steam theme
if command -v python >/dev/null 2>&1; then
    cd $HOME/.local/share/steam-adwaita && ./install.py --uninstall > /dev/null 2>&1
fi

# Remove Spotify theme
if command -v spicetify >/dev/null 2>&1; then
    spicetify restore
fi

# Remove GTK theme
gsettings set org.gnome.desktop.interface gtk-theme Adwaita

# Remove Vicinae theme
vicinae theme set vicinae-dark

echo "Uninstalled theme hook!"

omarchy-show-done
