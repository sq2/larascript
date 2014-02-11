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

PS3="Select a profile file: "
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
    if [[ $laravel_installer == "laravel" ]]; then
        # Use laravel.phar
        laravel new $domain
    else
        # Use create-project
        composer create-project laravel/laravel $domain --prefer-dist
    fi

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
    if [[ $public == "y" ]]; then
        # Move files
        cd public; mv * ../; cd ..

        # Cleanup. Should probably be done in .gitignore file instead.
        rm -rf public; rm readme.md; rm CONTRIBUTING.md

        # Fix paths
        gsed -i "s@/../bootstrap@/bootstrap@g" index.php
        gsed -i "s@/../public@/..@" bootstrap/paths.php

        PUBLIC_PATH="$WORK_PATH"
    else
        echo
        echo -n "Move public files to public_html folder? (y/n) [n] : "
        read -e publichtml
        if [[ $publichtml == "y" ]]; then
            # Rename public to public_html.
            mv public public_html

            # Fix paths
            gsed -i "s@/../public@/../public_html@" bootstrap/paths.php

            PUBLIC_PATH="$WORK_PATH/public_html"
        else
            # Default public folder.
            PUBLIC_PATH="$WORK_PATH/public"
        fi
    fi

    # Make asset folders
    mkdir "$PUBLIC_PATH/img"
    mkdir "$PUBLIC_PATH/includes"

    # Copy .htaccess file to public
    if [[ -e "$PROFILE_PATH/src/public/.htaccess" ]]; then
        cp "$PROFILE_PATH/src/public/.htaccess" "$PUBLIC_PATH"
    fi
else
    # Set public folder.
    if [ -d "public" ]; then
        PUBLIC_PATH="$WORK_PATH/public"
    elif [[ -d "public_html" ]]; then
        PUBLIC_PATH="$WORK_PATH/public_html"
    else
        PUBLIC_PATH="$WORK_PATH"
    fi
fi

echo
echo "Public path is $PUBLIC_PATH"
echo


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
    gsed -i "s/'your-machine-name'/${hostnames_string%??}/" bootstrap/start.php

    # Make local config folder
    mkdir -p app/config/local

    # Add local config files
    printf "<?php\n\nreturn array(\n\n\t'debug' => true,\n\n\t'url' => 'http://$domain',\n\n);" > app/config/local/app.php

    if [[ -e "$PROFILE_PATH/src/app/config/local/session.php" ]]; then
        cp "$PROFILE_PATH/src/app/config/local/session.php" app/config/local/
        gsed -i "s/'lifetime' => 120/'lifetime' => $session_lifetime/" app/config/local/session.php

        if [[ "$session_domain" != "null" ]]; then
            gsed -i "s/'domain' => null/'domain' => '$domain'/" app/config/local/session.php
        fi
    fi

    # Set production debug to false
    gsed -i "s/'debug' => true/'debug' => false/" app/config/app.php
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
        gsed -i "s/'database' => 'database'/'database' => '$database'/" app/config/database.php
        gsed -i "s/'password'  => ''/'password'  => '$password'/" app/config/database.php
        # gsed -i "s/'username'  => 'root'/'username'  => '$username'/" app/config/database.php
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
        gsed -i "s/'lifetime' => 120/'lifetime' => $session_lifetime/" app/config/session.php

        cookie_suffix="_session"
        gsed -i "s/'cookie' => 'laravel_session'/'cookie' => '$appname$cookie_suffix'/" app/config/session.php

        # Workbench settings
        gsed -i "s/'name' => ''/'name' => '$workbench_author_name'/" app/config/workbench.php
        gsed -i "s/'email' => ''/'email' => '$workbench_email'/" app/config/workbench.php
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
        echo "Skipping. File custom.sh not found in $PROFILE_PATH"
    fi
fi

# Cache settings
gsed -i "s/'prefix' => 'laravel'/'prefix' => '$appname'/" app/config/cache.php


#-----------------------------------------------------------------------
# PACKAGES                                                             |
#-----------------------------------------------------------------------

# Load from packages folder.
echo
for f in "$SOURCE_PATH"/packages/*.sh; do
    filename=$(basename $f)
    package=${filename%.*}
    package=$(echo $package | tr "_" " ")

    if [[ $(autoloadCheck "$f"; echo $?) == 1 ]]; then
        echo -n "Add $package package? (y/n) [n] : "
        read -e load_package
    else
        load_package="y"
    fi

    if [[ $load_package == "y" ]]; then
        echo
        echo "Adding $package..."

        . "$f"
        echo
    else
        echo
    fi
done

# Load from profile packages folder.
# TODO: DRY this up
echo
for f in "$PROFILE_PATH"/packages/*.sh; do
    filename=$(basename $f)
    package=${filename%.*}
    package=$(echo $package | tr "_" " ")

    if [[ $(autoloadCheck "$f"; echo $?) == 1 ]]; then
        echo -n "Add $package package? (y/n) [n] : "
        read -e load_package
    else
        load_package="y"
    fi

    if [[ $load_package == "y" ]]; then
        echo
        echo "Adding $package..."

        . "$f"
        echo
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
if [[ $composer == "y" ]]; then
    composer update --dev
fi

# What else?
echo
echo "----------------------------------------------------------------"
echo "Larascript setup complete."
echo
echo "The following items will need to be handled manually (for now):"
echo
echo "Bring in Javascript, CSS and image assets."
echo "Error handling for missing pages."
echo "Setup virtual host and local domain. (Coming soon)"
echo
