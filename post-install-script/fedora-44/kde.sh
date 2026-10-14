#!/bin/bash

ENVIRONMENT_FILES_LOCATION="/etc/environment.d"

chex() {
    . ../shared/check-execution.sh
}

#===============================BEGIN===============================#
echo -e '\nWorking with packages...' && sleep 1

sudo dnf remove -y akregator dragon elisa-player mediawriter kcharselect khelpcenter im-chooser kjournald kaddressbook kamoso kde-connect kdebugsettings kleopatra kmahjongg kmail kmines kmouth kolourpaint kontact korganizer kpat krdc krfb ktnef neochat pim-sieve-editor pim-data-exporter gnome-abrt qrca setroubleshoot plasma-welcome filelight && \

chex
#================================END================================#

#===============================BEGIN===============================#
echo -e '\nWorking with environment files...' && sleep 1

sudo mkdir -p $ENVIRONMENT_FILES_LOCATION && \
sudo touch $ENVIRONMENT_FILES_LOCATION/custom.conf && \
sudo tee $ENVIRONMENT_FILES_LOCATION/custom.conf << 'EOF'
QT_SCALE_FACTOR_ROUNDING_POLICY=RoundPreferFloor
EOF

chex
#================================END================================#
