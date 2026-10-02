#!/bin/bash

ENVIRONMENT_FILES_LOCATION="/etc/environment.d/"
PLASMA_THEMES_LOCATION="/usr/share/plasma/desktoptheme/"

chex() {
    . ./check-execution.sh
}

#===============================BEGIN===============================#
echo -e '\nWorking with packages...' && sleep 2

sudo apt purge -y akregator dragonplayer gimp juk kaddressbook kdeconnect kmag kmail kmousetool kmouth konqueror khelpcenter kontrast korganizer pim-data-exporter pim-sieve-editor plasma-welcome sweeper xterm kwrite && \
sudo apt autoremove -y --purge

chex
#================================END================================#

#===============================BEGIN===============================#
echo -e '\nWorking with environment files...' && sleep 2

sudo touch $ENVIRONMENT_FILES_LOCATION/custom.conf
sudo tee $ENVIRONMENT_FILES_LOCATION/custom.conf << 'EOF'
QT_SCALE_FACTOR_ROUNDING_POLICY=RoundPreferFloor
EOF

chex
#================================END================================#

#===============================BEGIN===============================#
echo -e '\nWorking with Plasma themes...' && sleep 2

sudo cp -r breeze-custom $PLASMA_THEMES_LOCATION

chex
#================================END================================#
