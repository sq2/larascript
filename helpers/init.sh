# Set paths
WORK_PATH=$(pwd)

# Get hostname
hostname=$(hostname)

# Include functions
. "$SOURCE_PATH"/helpers/functions.sh

# Make sure required commands are available.
commandCheck gsed
commandCheck php

if ! commandExists "composer" ; then
    echo
    echo -n "Can't find Composer. Install now? (y/n) [n] : "
    read -e install_composer
    if [[ $install_composer == "y" ]]; then
        echo "Installing Composer..."
        curl -sS https://getcomposer.org/installer | php
        chmod 755 composer.phar
        sudo mv composer.phar /usr/local/bin/composer
        sudo chown $USER /usr/local/bin/composer
    fi
fi

commandCheck composer
