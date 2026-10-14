#!/bin/bash
# Tested on Fedora 44 [Plasma 6.7.5]

GRUB_FILE="/etc/default/grub"
LOCALE_FILE="/etc/locale.conf"
TARGET_LOCALE="en_GB.UTF-8"
FONTS_LOCATION="/usr/local/share/fonts/"

chex() {
    . ../shared/check-execution.sh
}

if [ $USER = root ]; then
    echo 'Script must not be run on root!'
    exit 1
fi

#===============================BEGIN===============================#
echo -e '\nWorking with GRUB...' && sleep 1

sudo cp $GRUB_FILE $GRUB_FILE.bak && \
sudo sed -i -e 's/^GRUB_TIMEOUT=[0-9]*/GRUB_TIMEOUT=0/' $GRUB_FILE && \
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

chex
#================================END================================#

#===============================BEGIN===============================#
echo -e '\nWorking with locales (Step 1)...' && sleep 1

LANG_CODE=$(echo "$TARGET_LOCALE" | cut -d'_' -f1)

if locale -a | grep -qi "${TARGET_LOCALE}"; then
    echo "Locale ${TARGET_LOCALE} is already available."
else
    echo "Enabling locale by installing glibc-langpack-${LANG_CODE}..."
    sudo dnf install -y "glibc-langpack-${LANG_CODE}"
fi

chex
#================================END================================#

#===============================BEGIN===============================#
echo -e '\nWorking with locales (Step 2)...' && sleep 1

sudo cp "$LOCALE_FILE" "$LOCALE_FILE.bak" && \
(
sudo tee "$LOCALE_FILE" << 'EOF'
LANG=en_US.UTF-8
LANGUAGE=en_US:en
LC_TIME=en_GB.UTF-8
EOF
)

chex
#================================END================================#

#===============================BEGIN===============================#
echo -e '\nWorking with fonts...' && sleep 1

sudo mkdir -p $FONTS_LOCATION && \
sudo cp -r ../shared/fira-mono "$FONTS_LOCATION" && \
sudo cp ../shared/local.conf /etc/fonts/ && \
sudo fc-cache -fv

chex
#================================END================================#

#===============================BEGIN===============================#
echo -e '\nWorking with specific desktop environment settings...' && sleep 1

read -p "Enter your desktop environment (kde): " env

case "$env" in
    kde)
        . ./kde.sh
        ;;
    *)
        echo "Enter 'kde'."
        exit 1
        ;;
esac

chex
#================================END================================#

#===============================BEGIN===============================#
echo -e '\nWorking with home directory...' && sleep 1

EXCEPTIONS=(
    ".bashrc"
    ".bash_profile"
    ".bash_history"
    ".bash_logout"
    "post-install-script"
)

shopt -s dotglob nullglob

for item in "$HOME"/*; do
    name=$(basename "$item")
    
    is_exception=false
    for exception in "${EXCEPTIONS[@]}"; do
        if [[ "$name" == "$exception" ]]; then
            is_exception=true
            break
        fi
    done
    
    if $is_exception; then
        continue
    fi

    rm -rf "$item" 2>/dev/null
done

shopt -u dotglob nullglob

chex
#================================END================================#

echo -e '\nReboot...'

sleep 1

sudo reboot
