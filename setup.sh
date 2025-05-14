#!/bin/bash
set -e

# Ensure script is run as root or with sudo
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root or with sudo" >&2
    exit 1
fi

# Installing core packages
echo "Updating system and installing required packages..."

pacman -Syu --noconfirm
pacman -S --noconfirm \
    hyprland waybar hyprpaper hyprlock kitty wofi wlogout \
    networkmanager blueman \
    gtk3 gtk4 qt5ct qt6ct \
    lxappearance lxappearance-gtk3 \
    libappindicator-gtk3 libdbusmenu-gtk3 \
    imagemagick brightnessctl dunst ttf-font-awesome noto-fonts

# Enable services
systemctl enable NetworkManager
systemctl enable bluetooth

# Clone your dotfiles repo
echo "Cloning dotfiles..."
if [ ! -d "/home/$SUDO_USER/dotfiles" ]; then
    sudo -u "$SUDO_USER" git clone https://github.com/vatsl808/dotfiles.git "/home/$SUDO_USER/dotfiles"
fi

DOTFILES="/home/$SUDO_USER/dotfiles"

# Copy .config files
echo "Copying .config files..."
sudo -u "$SUDO_USER" cp -rT "$DOTFILES/.config" "/home/$SUDO_USER/.config"

# Set wallpaper directories
echo "Setting up wallpapers..."
sudo -u "$SUDO_USER" mkdir -p "/home/$SUDO_USER/wallpaper"
sudo -u "$SUDO_USER" cp -r "$DOTFILES/imgs/wallpaper/"* "/home/$SUDO_USER/wallpaper/"

sudo -u "$SUDO_USER" mkdir -p "/home/$SUDO_USER/hyprlock_wall"
sudo -u "$SUDO_USER" cp -r "$DOTFILES/imgs/hyprlock_wall/"* "/home/$SUDO_USER/hyprlock_wall/"

# Install fonts
echo "Installing fonts..."
FONT_DIR="/home/$SUDO_USER/.local/share/fonts"
sudo -u "$SUDO_USER" mkdir -p "$FONT_DIR"
sudo -u "$SUDO_USER" cp -r "$DOTFILES/fonts/"* "$FONT_DIR"
sudo -u "$SUDO_USER" fc-cache -fv

# Set ownership
chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.config" "/home/$SUDO_USER/wallpaper" "/home/$SUDO_USER/hyprlock_wall" "$FONT_DIR"

echo "✅ Installation complete!"
echo "You can now start Hyprland and use your custom config."

