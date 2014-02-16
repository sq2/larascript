#!/bin/bash

#
# Larascript. Bash interactive Laravel setup script, for Mac OS.
# https://github.com/sq2/larascript
# By @Codepl
#
# Works fine on my Mac. Use at your own risk.
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

# Choose a profile.
declare -a profiles
for f in $(find "$SOURCE_PATH/profiles" -maxdepth 1 -type d); do
    name=$(basename "$f")

    if [[ "$name" != "profiles" ]]; then
        profiles+=("$name")
    fi
done

PS3="Select a profile: "
select profile in "${profiles[@]}"; do
    if [[ $(containsElement "$profile" "${profiles[@]}"; echo $?) == 1 ]]; then
        printf "\nInvalid option, try again.\n"; continue;
    fi

    case "$profile" in
        "$profile") break;;
    esac
done
profile=${profile:-default}
printf "\n$profile profile selected\n"

# Set selected profile path
PROFILE_PATH="$SOURCE_PATH/profiles/$profile"

# Load default profile config so custom profile config can override defaults.
if [[ "$profile" != "default" ]]; then
    . "$SOURCE_PATH/profiles/default/config.sh"
fi

# Load custom profile config file.
. "$PROFILE_PATH/config.sh"

# App name
echo
echo -n "App name? (Perhaps the domain name without the extension) : "
read appname

# Local domain name
echo
read -p "Local domain name? ["$appname.dev"] : " domain
domain=${domain:-"$appname.dev"}

# Create new laravel project
echo
echo -n "Create a new Laravel app? (y/n) [n] : "
read -e laravel
if [[ $laravel == "y" ]]; then
    if [[ $laravel_installer != "composer" ]]; then
        if ! commandExists laravel ; then
            echo -n "The laravel.phar installer cannot be found. Install it now? (y/n) [n] : "
            read -e install_laravel_phar
            if [[ $install_laravel_phar == "y" ]]; then
                curl -O http://laravel.com/laravel.phar
                chmod 755 laravel.phar
                mv laravel.phar /usr/local/bin/laravel
            fi
        fi

        if commandExists laravel ; then
            # Use laravel.phar
            laravel new $domain
        else
            echo "laravel.phar installation failed. Trying composer..."
            laravel_installer="composer"
        fi
    fi

    if [[ $laravel_installer == "composer" ]]; then
        # Use create-project
        composer create-project laravel/laravel $domain --prefer-dist
    fi

    cd $domain
    WORK_PATH=$(pwd)
fi


#-----------------------------------------------------------------------
# DEPLOYMENT CONFIG                                                    |
#-----------------------------------------------------------------------

# Set public folder.
if [ -d "public" ]; then
    PUBLIC_PATH="$WORK_PATH/public"
    PUBLIC_DIR="/public"
elif [[ -d "public_html" ]]; then
    PUBLIC_PATH="$WORK_PATH/public_html"
    PUBLIC_DIR="/public_html"
else
    PUBLIC_PATH="$WORK_PATH"
    PUBLIC_DIR=""
fi

# Move public files to root. Shit happens.
if [ -d "public" ]; then
    echo
    echo -n "Move public files to root for shared hosting? (y/n) [n] : "
    read -e public
    if [[ $public == "y" ]]; then
        # Move files
        cd public; mv * ../; cd ..

        # Update path
        PUBLIC_PATH="$WORK_PATH"
        PUBLIC_DIR=""

        # Cleanup and add more items to .gitignore since public is root.
        rm -rf public;
        addLine "readme.md" ".gitignore"
        addLine "CONTRIBUTING.md" ".gitignore"
        addLine "codeception.yml" ".gitignore"

        # Fix paths
        stringReplace "@g" "/../bootstrap" "/bootstrap" index.php
        stringReplace "@" "/../public" "/.." bootstrap/paths.php

    else
        echo
        echo -n "Move public files to public_html folder? (y/n) [n] : "
        read -e publichtml
        if [[ $publichtml == "y" ]]; then
            # Rename public to public_html.
            mv public public_html

            # Update path
            PUBLIC_PATH="$WORK_PATH/public_html"
            PUBLIC_DIR="/public_html"

            # Fix paths
            stringReplace "@" "/../public" "/../public_html" bootstrap/paths.php
        else
            # Default public folder.
            PUBLIC_PATH="$WORK_PATH/public"
            PUBLIC_DIR="/public"
        fi
    fi

    # Copy .htaccess file to public
    if [[ -e "$PROFILE_PATH/src/public/.htaccess" ]]; then
        cp "$PROFILE_PATH/src/public/.htaccess" "$PUBLIC_PATH"
    fi

    if [[ $PUBLIC_DIR == "" ]]; then
        # Append to .htaccess file
        cat "$SOURCE_PATH/src/secure_htaccess" >> .htaccess
    fi
fi

echo
echo "NOTE: Public path is $PUBLIC_PATH"


#-----------------------------------------------------------------------
# LOCAL                                                                |
#-----------------------------------------------------------------------

# Create a local environment
echo
echo -n "Set up local environment? (y/n) [n] : "
read -e environment
if [[ $environment == "y" ]]; then
    # Update hostnames
    hostnames_string=$(printf "'%s', " "${hostnames[@]}")
    stringReplace "/" "'your-machine-name'" "${hostnames_string%??}" bootstrap/start.php

    # Make local config folder
    mkdir -p app/config/local

    # Add local config files
    printf "<?php\n\nreturn array(\n\n\t'debug' => true,\n\n\t'url' => 'http://$domain',\n\n);" > app/config/local/app.php

    if [[ -e "$PROFILE_PATH/src/app/config/local/session.php" ]]; then
        cp "$PROFILE_PATH/src/app/config/local/session.php" app/config/local/
        stringReplace "/" "'lifetime' => 120" "'lifetime' => $session_lifetime" app/config/local/session.php

        if [[ "$session_domain" != "null" ]]; then
            stringReplace "/" "'domain' => null" "'domain' => '$domain'" app/config/local/session.php
        fi
    fi

    # Set production debug to false
    stringReplace "/" "'debug' => true" "'debug' => false" app/config/app.php
fi

# Create mysql database
if [[ $mysql_skip == false ]]; then
    echo
    echo -n "Does this app require a MySql database? (y/n) [n] : "
    read -e mysqldb
    if [[ $mysqldb == 'y' ]]; then
        echo -n "What is the name of the database for this app? : "
        read -e database

        echo -n "Enter a database password? : "
        read -e password

        echo "Creating MySQL database"
        echo "Enter system password"
        sudo mysql -u$mysql_user -p$password -e"CREATE DATABASE $database"

        echo Updating database configuration file
        stringReplace "/" "'database' => 'database'" "'database' => '$database'" app/config/database.php
        stringReplace "/" "'password'  => ''" "'password'  => '$password'" app/config/database.php
        # stringReplace "/" "'username'  => 'root'" "'username'  => '$username'" app/config/database.php
    fi
fi


#-----------------------------------------------------------------------
# PROFILE CUSTOMIZATIONS                                               |
#-----------------------------------------------------------------------

# Change Laravel settings.
if [[ "$profile" != "default" ]]; then
    echo
    echo -n "Apply profile configuration settings? (y/n) [n] : "
    read -e settings
    if [[ $settings == "y" ]]; then
        # Session settings
        echo
        echo "Applying settings..."

        # Session settings
        stringReplace "/" "'lifetime' => 120" "'lifetime' => $session_lifetime" app/config/session.php
        stringReplace "/" "'cookie' => 'laravel_session'" "'cookie' => '${appname}_session'" app/config/session.php

        # Workbench settings
        stringReplace "/" "'name' => ''" "'name' => '$workbench_author_name'" app/config/workbench.php
        stringReplace "/" "'email' => ''" "'email' => '$workbench_email'" app/config/workbench.php
    fi
fi

# Load customizations from selected profile.
echo
echo -n "Add customizations? (y/n) [n] : "
read -e custom
if [[ $custom == "y" ]]; then
    if [[ -e "$PROFILE_PATH/custom.sh" ]]; then
        . "$PROFILE_PATH/custom.sh"
    else
        echo
        echo "SKIPPING: File custom.sh not found in $PROFILE_PATH"
    fi
fi

# Cache settings
stringReplace "/" "'prefix' => 'laravel'" "'prefix' => '$appname'" app/config/cache.php


#-----------------------------------------------------------------------
# PACKAGES                                                             |
#-----------------------------------------------------------------------

# Load packages.
echo
for f in "$SOURCE_PATH"/packages/*.sh "$PROFILE_PATH"/packages/*.sh; do
    [[ -e "$f" ]] || continue

    cd $WORK_PATH

    filename=$(basename $f)
    package=${filename%.*}
    package=$(echo $package | tr "_" " ")

    if [[ $(autoloadCheck "$f"; echo $?) != 0 ]]; then
        echo -n "Add $package package? (y/n) [n] : "
        read -e load_package
    else
        load_package="y"
    fi

    if [[ $load_package == "y" ]]; then
        echo
        echo "Adding $package..."

        . "$f"
    fi

    echo
done


#-----------------------------------------------------------------------
# FINAL                                                                |
#-----------------------------------------------------------------------

# Composer update
echo
echo -n "Run Composer update? (y/n) [n] : "
read -e composer
if [[ $composer == "y" ]]; then
    composer update --dev
fi

# What else?
echo
echo "----------------------------------------------------------------"
echo "Larascript Setup Complete"
echo "----------------------------------------------------------------"
echo
echo "The following items will need to be handled manually (for now):"
echo
echo "Bring in Javascript, CSS and image assets."
echo "Error handling for missing pages."
echo "Setup virtual host and local domain. (Coming soon)"
echo
