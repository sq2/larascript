#!/bin/bash

# Get the source directory
DIR="$( cd "$( echo "${BASH_SOURCE[0]%/*}" )"; pwd )"


#-----------------------------------------------------------------------
# START                                                                |
#-----------------------------------------------------------------------

echo
echo "Get Started Configuring a New Laravel Website"
echo

# App name?
echo
echo -n "What is the local domain name of this app, without the extension? : "
read appname
domain="$appname.dev"

# Create new laravel Project
echo
echo -n "Create a new Laravel app? (y/n) : "
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
fi


#-----------------------------------------------------------------------
# DEPLOYMENT CONFIG                                                    |
#-----------------------------------------------------------------------

# Move public files to root. Shit happens.
echo
echo -n "Move public files to root for shared hosting? (y/n) : "
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
    cp $DIR/src/public/.htaccess .
else
    # Cleanup. Should probably be done in Git ignore file instead.
    cd public
    rm readme.md; rm CONTRIBUTING.md
    cd ..

    # Copy .htaccess file to public
    cp $DIR/src/public/.htaccess public
fi


#-----------------------------------------------------------------------
# LOCAL                                                                |
#-----------------------------------------------------------------------

# Create a local environment
echo
echo -n "Set up local environment? (y/n) : "
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
echo -n "Add custom libraries and settings to $domain? (y/n) : "
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
        cat "$DIR/src/app/start/global.php" >> app/start/global.php

        # Add extra files for easier management.
        printf "<?php\n\n// View composers" > app/composers.php

        # Views
        mkdir app/views/layouts
        mkdir app/views/auth
        mkdir app/views/errors

        # Add asset folders
        echo "Adding asset folders..."
        mkdir img
        mkdir includes
        mkdir javascript
        mkdir less

        # Copy library folders
        # echo "Copying library folders..."
        # cp -R $DIR/lib app/

        # Add service providers
        # echo "Adding service providers..."
        # gsed -i "/WorkbenchServiceProvider/a \\\t\t'VendorName\\\Product\\\ProductServiceProvider'," app/config/app.php

        # Add facades
        echo "Adding facades..."
        gsed -i "/'View'/a \\\t\t'Carbon' => 'Carbon\\\Carbon'," app/config/app.php

        # Add psr-0 entries
        # echo "Adding psr-0 entries..."
        # php $DIR/scripts/add_to_json.php composer.json .autoload.psr-0.Helpers.app/lib

        # Add psr-4 entries
        # echo "Adding psr-4 entries..."
        # php $DIR/scripts/add_to_json.php composer.json ".autoload.psr-4.Helpers\\.app/lib"

        # Add to classmap
        # echo "Adding classmap entries..."
        # php $DIR/scripts/add_to_json.php composer.json ".autoload.classmap.app/composers" array
fi


#-----------------------------------------------------------------------
# PACKAGES                                                             |
#-----------------------------------------------------------------------

# Add Way/Generators package to composer.json
echo
echo -n "Add Way/Generators package to $domain? (y/n) : "
read -e generators
if [[ $generators == "y" ]]
    then
        echo "Adding Way/Generators to $domain..."

        composer require --dev --no-update way/generators:dev-master

        # Add service provider
        gsed -i "/WorkbenchServiceProvider/a \\\t\t'Way\\\Generators\\\GeneratorsServiceProvider'," app/config/app.php
fi

# Add Clockwork package to composer.json. Recommended by Jeffrey Way at laracasts.com.
echo
echo -n "Add itsgoingd/clockwork package to $domain? (y/n) : "
read -e clockwork
if [[ $clockwork == "y" ]]
    then
        echo "Adding Clockwork to $domain..."

        composer require --dev --no-update itsgoingd/clockwork:dev-master

        # Add service provider
        gsed -i "/WorkbenchServiceProvider/a \\\t\t'Clockwork\\\Support\\\Laravel\\\ClockworkServiceProvider'," app/config/app.php

        # Add facade
        gsed -i "/'View'/a \\\t\t'Clockwork' => 'Clockwork\\\Support\\\Laravel\\\Facade'," app/config/app.php

        # Append to local.php file
        cat "$DIR/src/vendor/clockwork.php" >> app/start/local.php
fi


#-----------------------------------------------------------------------
# FINAL                                                                |
#-----------------------------------------------------------------------

# Composer update
echo
echo -n "Run Composer update? (y/n) : "
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
echo "Bring in Javascript and CSS assets."
echo "Error handling for missing pages."
echo
