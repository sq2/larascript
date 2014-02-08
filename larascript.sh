#!/bin/bash

#
# Larascript. Bash interactive Laravel setup script.
# https://github.com/sq2/larascript
# By @Codepl
#


# Set the source path
SOURCE_PATH="$( cd "$( echo "${BASH_SOURCE[0]%/*}" )"; pwd )"

# Include any initializations and functions
. "$SOURCE_PATH"/helpers/init.sh


#-----------------------------------------------------------------------
# START                                                                |
#-----------------------------------------------------------------------

echo
echo "Get Started Configuring a New Laravel 4.1 Website"
echo

# App name
echo
echo -n "App name? (Maybe the domain name without the extension) : "
read appname

# Local domain name
echo
read -p "Local domain name? ["$appname.dev"] : " domain
domain=${domain:-"$appname.dev"}

# Create new laravel project
echo
echo -n "Create a new Laravel app? (y/n) [n] : "
read -e laravel
if [[ $laravel == "y" ]]
then
    # Assumes that laravel.phar is available globally.
    # wget http://laravel. com/laravel.phar
    # chmod 755 laravel.phar
    # mv laravel.phar /usr/local/bin/laravel
    laravel new $domain

    # Use create-project instead
    # composer create-project laravel/laravel $domain --prefer-dist

    cd $domain
    WORK_PATH=$(pwd)
fi


#-----------------------------------------------------------------------
# DEPLOYMENT CONFIG                                                    |
#-----------------------------------------------------------------------

# Move public files to root. Shit happens.
if [ -d "public" ]; then
    echo
    echo -n "Move public files to root for shared hosting? (y/n) [n] : "
    read -e public
    if [[ $public == "y" ]]
    then
        # Move files and cleanup
        cd public; mv * ../; cd ..
        rm -rf public; rm readme.md; rm CONTRIBUTING.md

        # Fix paths
        gsed -i "s@/../bootstrap@/bootstrap@g" index.php
        gsed -i "s@/../public@/..@" bootstrap/paths.php

        # Copy .htaccess file
        cp "$SOURCE_PATH"/src/public/.htaccess .

        # Make asset folders
        mkdir img
        mkdir includes
    else
        cd public

        # Make asset folders
        mkdir img
        mkdir includes

        # Cleanup. Should probably be done in Git ignore file instead.
        rm readme.md; rm CONTRIBUTING.md

        cd ..

        # Copy .htaccess file to public
        cp "$SOURCE_PATH"/src/public/.htaccess public
    fi
fi


#-----------------------------------------------------------------------
# LOCAL                                                                |
#-----------------------------------------------------------------------

# Create a local environment
echo
echo -n "Set up local environment? (y/n) [n] : "
read -e environment
if [[ $environment == "y" ]]
then
    # Change to your hostnames.
    gsed -i "s/'your-machine-name'/'MacPro1.local', 'MacPro4.local'/" bootstrap/start.php

    # Make local config folder
    mkdir -p app/config/local

    # Add local config files
    printf "<?php\n\nreturn array(\n\n'debug' => true,\n\n'url' => 'http://$domain',\n\n);" > app/config/local/app.php

    # Set production debug to false
    gsed -i "s/'debug' => true/'debug' => false/" app/config/app.php
fi

# Create mysql database
echo
echo -n "Does your app require a MySql database? : (y/n) "
read -e mysqldb
if [[ $mysqldb == 'y' ]]
then
    echo -n "What is the name of the database for this app? : "
    read -e database

    echo -n "Enter a database password? : "
    read -e password

    echo "Creating MySQL database"
    echo "Enter system password"
    sudo mysql -uroot -p$password -e"CREATE DATABASE $database"

    echo Updating database configuration file
    gsed -i "s/'database' => 'database'/'database' => '$database'/" app/config/database.php
    gsed -i "s/'password'  => ''/'password'  => '$password'/" app/config/database.php
    # gsed -i "s/'username'  => 'root'/'username'  => '$username'/" app/config/database.php
fi


#-----------------------------------------------------------------------
# CUSTOMIZE                                                            |
#-----------------------------------------------------------------------

# Add custom libraries to service providers and facades
echo
echo -n "Add custom libraries and settings to $domain? (y/n) [n] : "
read -e custom
if [[ $custom == "y" ]]
then
    # Session settings
    echo
    echo "Configuring settings..."
    gsed -i "s/'lifetime' => 120/'lifetime' => 240/" app/config/session.php
    gsed -i "s/'cookie' => 'laravel_session'/'cookie' => '$appname_session'/" app/config/session.php

    # Cache settings
    gsed -i "s/'prefix' => 'laravel'/'prefix' => '$appname'/" app/config/cache.php

    # Workbench settings
    # gsed -i "s/'name' => ''/'name' => 'Your Name'/" app/config/workbench.php
    # gsed -i "s/'email' => ''/'email' => 'Your Email Address'/" app/config/workbench.php

    # Append to global.php file
    cat "$SOURCE_PATH/src/app/start/global.php" >> app/start/global.php

    # Add extra files for easier management.
    printf "<?php\n\n// View composers" > app/composers.php

    # Views
    mkdir app/views/layouts
    mkdir app/views/auth
    mkdir app/views/errors

    # Add asset source folders
    echo "Adding asset source folders..."
    mkdir javascript
    mkdir less

    # Copy library folders
    # echo "Copying library folders..."
    # cp -R "$SOURCE_PATH"/lib app/

    # Add service providers
    # echo "Adding service providers..."
    # add_service_provider "VendorName\Product\ProductServiceProvider"

    # Add aliases
    echo "Adding facade aliases..."
    add_alias "Carbon" "Carbon\Carbon"

    # Add psr-0 entries
    # echo "Adding psr-0 entries..."
    # add_to_composer ".autoload.psr-0.Helpers.app/lib"

    # Add psr-4 entries
    # echo "Adding psr-4 entries..."
    # add_to_composer ".autoload.psr-4.Helpers\\.app/lib"

    # Add to classmap
    # echo "Adding classmap entries..."
    # add_to_composer ".autoload.classmap.app/composers" array
fi


#-----------------------------------------------------------------------
# PACKAGES                                                             |
#-----------------------------------------------------------------------

echo
for f in "$SOURCE_PATH"/packages/*.sh; do
    filename=$(basename $f)
    package=${filename%.*}
    package=$(echo $package | tr "_" " ")

    ask="packagedev"

    echo -n "Add $package package? (y/n) [n] : "
    read -e ask
    if [[ $ask == "y" ]]
    then
        echo
        echo "Adding $package..."
        echo

        . "$f"
    else
        echo
    fi
done


#-----------------------------------------------------------------------
# FINAL                                                                |
#-----------------------------------------------------------------------

# Composer update
echo
echo -n "Run Composer update? (y/n) [n] : "
read -e composer
if [[ $composer == "y" ]]
then
    composer update
fi

# What else?
echo
echo "----------------------------------------------------------------"
echo
echo "The following items will need to be handled manually (for now):"
echo
echo "Bring in Javascript, CSS and image assets."
echo "Error handling for missing pages."
echo "Setup virtual host and local domain. (Coming soon)"
echo
