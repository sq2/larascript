#!/bin/bash

#
# Larascript. Bash interactive Laravel setup script, for Mac OS.
# https://github.com/sq2/larascript
# By @Codepl
#
# Works fine on my Mac. Use at your own risk.
#


echo
echo "Larascript is running. Press ctrl+z to exit early."
echo

# Set the source path.
SOURCE_PATH="$( cd "$( echo "${BASH_SOURCE[0]%/*}" )"; pwd )"

# Include any initializations and functions.
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
        printf "\nInvalid option number, try again.\n"; continue;
    fi

    case "$profile" in
        "$profile") break;;
    esac
done
profile=${profile:-default}
printf "NOTE: '$profile' profile selected\n"

# Set selected profile path
PROFILE_PATH="$SOURCE_PATH/profiles/$profile"

# Load default profile config so custom profile config can override defaults.
if [[ "$profile" != "default" ]]; then
    . "$SOURCE_PATH/profiles/default/config.sh"
fi

# Load custom profile config file.
. "$PROFILE_PATH/config.sh"


# Choose a name for this app. It will be used to replace some Laravel
# defaults.
echo
echo -n "App name? (Perhaps the domain name without the extension) : "
read appname


# Local domain name
echo
read -p "Local domain name? ["$appname.dev"] : " domain
domain=${domain:-"$appname.dev"}


#-----------------------------------------------------------------------
# LARAVEL                                                              |
#-----------------------------------------------------------------------

# Create new laravel project.
echo
echo -n "Create a new Laravel app? (y/n) [n] : "
read -e laravel
if [[ $laravel == "y" ]]; then
    if [[ $laravel_installer != "composer" ]]; then
        if ! commandExists laravel ; then
            echo -n "The laravel.phar installer cannot be found. Install it now? (y/n) [n] : "
            read -e install_laravel_phar
            if [[ $install_laravel_phar == "y" ]]; then
                echo "Installing laravel.phar..."
                curl -O http://laravel.com/laravel.phar
                chmod 755 laravel.phar
                mv laravel.phar /usr/local/bin/laravel
            fi
        fi

        if commandExists laravel ; then
            # Use laravel.phar.
            laravel new $domain
        else
            echo "Installation of laravel.phar failed. Trying composer..."
            laravel_installer="composer"
        fi
    fi

    if [[ $laravel_installer == "composer" ]]; then
        # Use composer create-project.
        echo "Creating Laravel project using Composer..."
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
        echo "Moving public files to root folder..."

        # Move files
        cd public; mv * ../; cd ..

        # Update path.
        PUBLIC_PATH="$WORK_PATH"
        PUBLIC_DIR=""

        # Cleanup and add more items to .gitignore since public is root, for
        # greater security.
        rm -rf public;
        addLine "readme.md" .gitignore
        addLine "CONTRIBUTING.md" .gitignore
        addLine "codeception.yml" .gitignore
        addLine "server.php" .gitignore

        # Fix paths.
        stringReplace "@ g" "/../bootstrap" "/bootstrap" index.php
        stringReplace "@" "/../public" "/.." bootstrap/paths.php
    else
        echo -n "Move public files to public_html folder? (y/n) [n] : "
        read -e publichtml
        if [[ $publichtml == "y" ]]; then
            echo "Moving public files to public_html folder..."

            # Rename public to public_html.
            mv public public_html

            # Update path
            PUBLIC_PATH="$WORK_PATH/public_html"
            PUBLIC_DIR="/public_html"

            # Fix paths.
            stringReplace "@" "/../public" "/../public_html" bootstrap/paths.php
        fi
    fi

    # Copy .htaccess file to public.
    if [[ -e "$PROFILE_PATH/src/public/.htaccess" ]]; then
        echo "Copying .htaccess file to public folder..."
        cp "$PROFILE_PATH/src/public/.htaccess" "$PUBLIC_PATH"
    fi

    # For added security, block some files from running when pubic files
    # have been moved to the root folder.
    if [[ $PUBLIC_DIR == "" ]]; then
        cat "$SOURCE_PATH/src/secure_htaccess" >> .htaccess
    fi
fi

echo "NOTE: Public path is $PUBLIC_PATH"


#-----------------------------------------------------------------------
# LOCAL                                                                |
#-----------------------------------------------------------------------

# Create a local environment.
echo
echo -n "Set up local environment? (y/n) [n] : "
read -e environment
if [[ $environment == "y" ]]; then
    echo "Configuring local environment..."

    # Update hostnames
    hostnames_string=$(printf "'%s', " "${hostnames[@]}")
    stringReplace "/" "'your-machine-name'" "${hostnames_string%??}" bootstrap/start.php

    # Make local config folder.
    mkdir -p app/config/local

    # Add local config files.
    printf "<?php\n\nreturn array(\n\n\t'debug' => true,\n\n\t'url' => 'http://$domain',\n\n);" > app/config/local/app.php

    if [[ -e "$PROFILE_PATH/src/app/config/local/session.php" ]]; then
        cp "$PROFILE_PATH/src/app/config/local/session.php" app/config/local/
        stringReplace "/" "'lifetime' => 120" "'lifetime' => $session_lifetime" app/config/local/session.php

        if [[ "$session_domain" != "null" ]]; then
            stringReplace "/" "'domain' => null" "'domain' => '$domain'" app/config/local/session.php
        fi
    fi

    # Set production debug to false.
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
        stringReplace "/" "'username'  => 'root'" "'username'  => '$mysql_user'" app/config/database.php
        stringReplace "/" "'password'  => ''" "'password'  => '$password'" app/config/database.php
    fi
fi


#-----------------------------------------------------------------------
# PROFILE CUSTOMIZATIONS                                               |
#-----------------------------------------------------------------------

# Change Laravel settings.
# Load customizations from selected profile.
echo
echo -n "Apply profile customizations and configurations? (y/n) [n] : "
read -e custom
if [[ $custom == "y" ]]; then
    if [[ "$profile" != "default" ]]; then
        # Session settings.
        echo "Applying settings..."

        # Session settings.
        stringReplace "/" "'lifetime' => 120" "'lifetime' => $session_lifetime" app/config/session.php
        stringReplace "/" "'cookie' => 'laravel_session'" "'cookie' => '${appname}_session'" app/config/session.php

        # Workbench settings.
        stringReplace "/" "'name' => ''" "'name' => '$workbench_author_name'" app/config/workbench.php
        stringReplace "/" "'email' => ''" "'email' => '$workbench_email'" app/config/workbench.php
    fi

    if [[ -e "$PROFILE_PATH/custom.sh" ]]; then
        echo "Applying customizations..."
        . "$PROFILE_PATH/custom.sh"
    else
        echo "SKIPPING: File custom.sh not found in $PROFILE_PATH"
    fi

    # Cache settings.
    stringReplace "/" "'prefix' => 'laravel'" "'prefix' => '$appname'" app/config/cache.php
fi


#-----------------------------------------------------------------------
# BOWER                                                                |
#-----------------------------------------------------------------------

# Load Bower packages.
if [[ $bower_skip == false ]]; then
    echo
    echo "Loading Bower packages..."

    if ! commandExists bower ; then
        echo "SKIPPING: Bower not installed."
    else
        # Update Bower components folder.
        BOWER_DIR="${PUBLIC_DIR}/${bower_folder}"
        BOWER_DIR="${BOWER_DIR#/}"
        BOWER_PATH="${PUBLIC_PATH}/${bower_folder}"
        if [[ -e ".bowerrc" ]]; then
            php "$SOURCE_PATH/helpers/addToJson.php" "@directory@${BOWER_DIR}" key .bowerrc
        else
            cp "$SOURCE_PATH/src/bowerrc_template" .bowerrc
            stringReplace "@" "public/bower_components" "$BOWER_DIR" .bowerrc
        fi

        for f in "$SOURCE_PATH"/packages/bower/*.sh "$PROFILE_PATH"/packages/bower/*.sh; do
            [[ -e "$f" ]] || continue

            cd $WORK_PATH

            filename=$(basename $f)
            package=${filename%.*}
            package=$(echo $package | tr "_" " ")

            package_check=$(packageCheck "$f"; echo $?)
            if [[ $package_check == 2 ]]; then
                load_text="Loading"
                echo -n "Load $package Bower package? (y/n) [n] : "
                read -e load_package
            elif [[ $package_check == 0 ]]; then
                load_text="Autoloading"
                load_package="y"
            else
                continue
            fi

            if [[ $load_package == "y" ]]; then
                echo "$load_text $package Bower package..."

                . "$f"
            fi
        done
    fi
fi


#-----------------------------------------------------------------------
# PACKAGES                                                             |
#-----------------------------------------------------------------------

# Load packages.
echo
echo "Loading packages..."
for f in "$SOURCE_PATH"/packages/*.sh "$PROFILE_PATH"/packages/*.sh; do
    [[ -e "$f" ]] || continue

    cd $WORK_PATH

    filename=$(basename $f)
    package=${filename%.*}
    package=$(echo $package | tr "_" " ")

    package_check=$(packageCheck "$f"; echo $?)
    if [[ $package_check == 2 ]]; then
        load_text="Loading"
        echo -n "Load $package package? (y/n) [n] : "
        read -e load_package
    elif [[ $package_check == 0 ]]; then
        load_text="Autoloading"
        load_package="y"
    else
        continue
    fi

    if [[ $load_package == "y" ]]; then
        echo "$load_text $package package..."

        . "$f"
    fi
done


#-----------------------------------------------------------------------
# COMPOSER                                                             |
#-----------------------------------------------------------------------

# Composer update.
echo
echo -n "Run Composer update? (y/n) [n] : "
read -e composer
if [[ $composer == "y" ]]; then
    if [[ $composer_selfupdate == true ]]; then
        echo "Updating Composer..."
        composer self-update
    fi

    echo "Running composer update --dev..."
    composer update --dev
fi


#-----------------------------------------------------------------------
# VIRTUAL HOST                                                         |
#-----------------------------------------------------------------------

# Create a new virtual host.
if [[ $vhost_skip == false ]]; then
    echo
    echo -n "Create a new Apache virtual host for ${domain}? (y/n) [n] : "
    read -e vhost
    if [[ $vhost == "y" ]]; then
        # Ignore these log files created by Apache.
        addLine "localhost_access.log" .gitignore
        addLine "localhost_error.log" .gitignore

        if [[ $vhost_conf_path == *.conf ]]; then
            echo "Adding ${domain} to virtual host file..."

            if [[ -e "$vhost_conf_path" ]]; then
                CONF_PATH="$vhost_conf_path"
            fi
        else
            echo "Creating ${domain} virtual host file..."

            CONF_PATH="$vhost_conf_path/${domain}.conf"

            if [[ $vhost_sudo == true ]]; then
                sudo touch "$CONF_PATH"
            else
                touch "$CONF_PATH"
            fi
        fi

        if [[ -e "$CONF_PATH" ]]; then
            if [[ $vhost_sudo == true ]]; then
                vhost_run_sudo="s"
                sudo cat "$SOURCE_PATH/src/vhost_conf_template" >> "$CONF_PATH"
            else
                vhost_run_sudo=""
                cat "$SOURCE_PATH/src/vhost_conf_template" >> "$CONF_PATH"
            fi

            stringReplace "@ g ${vhost_run_sudo}" "/Sites/example.dev" "$WORK_PATH" "$CONF_PATH"
            stringReplace "@ g ${vhost_run_sudo}" "example.dev" "$domain" "$CONF_PATH"
            stringReplace "/ ${vhost_run_sudo}" "user@example.com" "$vhost_server_email" "$CONF_PATH"

            # Edit hosts file
            echo "Updating hosts file..."
            sudo php "$SOURCE_PATH"/helpers/addLine.php "127.0.0.1 $domain" /etc/hosts
            sudo php "$SOURCE_PATH"/helpers/addLine.php "127.0.0.1 www.${domain}" /etc/hosts

            sudo apachectl restart
        else
            echo "Virtual host not created. Path does not exist: $vhost_conf_path"
        fi
    fi
fi


#-----------------------------------------------------------------------
# DONE                                                                 |
#-----------------------------------------------------------------------

# What else?
echo
echo "----------------------------------------------------------------"
echo "Larascript Setup Complete"
echo "----------------------------------------------------------------"
echo
echo "The following items will need to be handled manually (for now):"
echo
echo "Add custom Javascript, CSS and image assets."
echo "Error handling for missing pages."
echo
