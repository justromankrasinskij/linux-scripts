#!/bin/bash
# Tested on Debian 13 [Plasma 6.3.6]

GRUB_FILE="/etc/default/grub"
LOCALE_FILE="/etc/default/locale"
LOCALE_GEN_FILE="/etc/locale.gen"
TARGET_LOCALE="en_GB.UTF-8 UTF-8"
APT_SOURCES_LIST="/etc/apt/sources.list"
FONTS_LOCATION="/usr/local/share/fonts/"
APT_MIRROR="debian.koyanet.lv"

chex() {
    . ./check-execution.sh
}

if [ $USER = root ]; then
    echo 'Script must not be run on root!'
    exit 1
fi

#===============================BEGIN===============================#
echo -e '\nWorking with GRUB...' && sleep 2

sudo cp $GRUB_FILE $GRUB_FILE.bak && \
sudo sed -i -e 's/^GRUB_TIMEOUT=[0-9]*/GRUB_TIMEOUT=0/' \
            -e 's/^#GRUB_TERMINAL=console/GRUB_TERMINAL=console/' $GRUB_FILE && \
sudo update-grub

chex
#================================END================================#

#===============================BEGIN===============================#
echo -e '\nWorking with locales (Step 1)...' && sleep 2

sudo cp $LOCALE_GEN_FILE $LOCALE_GEN_FILE.bak

if grep -qE "^#[[:space:]]*${TARGET_LOCALE}" "$LOCALE_GEN_FILE"; then
    sudo sed -i -E "s/^#[[:space:]]*(${TARGET_LOCALE})/\1/" "$LOCALE_GEN_FILE"
elif ! grep -qF "${TARGET_LOCALE}" "$LOCALE_GEN_FILE"; then
    echo "${TARGET_LOCALE}" | sudo tee -a "$LOCALE_GEN_FILE" > /dev/null
else
    echo "Locale is already active in ${LOCALE_GEN_FILE}."
fi

sudo locale-gen

chex
#================================END================================#

#===============================BEGIN===============================#
echo -e '\nWorking with locales (Step 2)...' && sleep 2

sudo cp $LOCALE_FILE $LOCALE_FILE.bak && \
(
sudo tee $LOCALE_FILE << 'EOF'
LANG="en_US.UTF-8"
LANGUAGE="en_US:en"
LC_TIME="en_GB.UTF-8"
EOF
) && sudo locale-gen

chex
#================================END================================#

#===============================BEGIN===============================#
echo -e '\nWorking with APT mirrors...' && sleep 2

sudo cp $APT_SOURCES_LIST $APT_SOURCES_LIST.bak && \
(
sudo tee $APT_SOURCES_LIST << EOF
deb http://$APT_MIRROR/debian trixie main contrib non-free non-free-firmware
deb http://$APT_MIRROR/debian trixie-updates main contrib non-free non-free-firmware
deb http://$APT_MIRROR/debian-security trixie-security main contrib non-free non-free-firmware
EOF
) && sudo apt update

chex
#================================END================================#

#===============================BEGIN===============================#
echo -e '\nWorking with fonts...' && sleep 2

sudo cp -r fira-mono $FONTS_LOCATION && \
sudo cp local.conf /etc/fonts/

chex
#================================END================================#

#===============================BEGIN===============================#
echo -e '\nWorking with specific desktop environment settings...' && sleep 2

read -p "Enter your desktop environment (kde): " env

case "$env" in
    kde)
        . ./kde.sh
        ;;
    *)
        echo "Enter 'kde' or 'gnome'."
        exit 1
        ;;
esac

chex
#================================END================================#

#===============================BEGIN===============================#
echo -e '\nWorking with home directory...' && sleep 2

EXCEPTIONS=(
    ".profile"
    ".bashrc"
    ".bash_history"
    ".bash_logout"
    ".gtkrc-2.0"
    "post-install-script"
)

shopt -s dotglob

for item in "$HOME"/*; do
    name=$(basename "$item")

    if [[ " ${EXCEPTIONS[*]} " =~ " ${name} " ]]; then
        continue
    fi

    rm -rf "$item" 2>/dev/null
done

shopt -u dotglob

chex
#================================END================================#

echo -e '\nReboot...'

sleep 2

sudo reboot
