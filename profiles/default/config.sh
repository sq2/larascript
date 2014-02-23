# Larascript default profile configuration file.
# Duplicate the profiles/default folder and rename it. Customize as needed.


#-----------------------------------------------------------------------
# LARAVEL INSTALLATION                                                 |
#-----------------------------------------------------------------------

# Larascript can install Laravel using one of the following methods.

# laravel method. The fastest way to install Laravel is to use the Laravel
# installer, laravel.phar. It should be installed globally and renamed
# from laravel.phar to laravel.
# Use the commands under the auto section below or see
# http://laravel.com/docs/installation

# composer method. Use Composer's create-project command. Composer must be
# installed globally and renamed from composer.phar to composer.
# See https://getcomposer.org/doc/00-intro.md#globally

# auto method. Check if laravel.phar is installed. If not, ask if it should
# be. If yes, it will be installed using the following commands. If it fails,
# the composer method will be used.
# curl -O http://laravel.com/laravel.phar
# chmod 755 laravel.phar
# mv laravel.phar /usr/local/bin/laravel

# Options: laravel, composer or auto
laravel_installer="auto"


#-----------------------------------------------------------------------
# COMPOSER                                                             |
#-----------------------------------------------------------------------

# Set to true to have Composer run a self update before updating your app.
composer_selfupdate=true


#-----------------------------------------------------------------------
# LARAVEL SETTINGS                                                     |
#-----------------------------------------------------------------------

# Local environment host names. Must be an array. Separate each value
# with a space. Ex. hostnames=("MacPro1.local" "Macbook.local"). Default
# value is the hostname for this computer.
hostnames=("$hostname")


# Session lifetime, in minutes.
session_lifetime="120"


# Workbench settings.
workbench_author_name=""
workbench_email=""


#-----------------------------------------------------------------------
# DATABASE                                                             |
#-----------------------------------------------------------------------

# MySql.

# Set to true to skip this section.
mysql_skip=false

# MySql username to use.
mysql_user="root"


#-----------------------------------------------------------------------
# BOWER                                                                |
#-----------------------------------------------------------------------

# Bower is a front-end package manager.

# Set to true to skip the prompt and not install any Bower packages.
bower_skip=false

# The name of the folder to store Bower components.
# Default: bower_components
bower_folder="bower_components"


#-----------------------------------------------------------------------
# VIRTUAL HOST                                                         |
#-----------------------------------------------------------------------

# The vhost settings determine how an Apache virtual host should be
# created. Additional setup may be needed to use virtual hosts.

# Set to true to skip the prompt and not setup a virtual host.
vhost_skip=false

# Your email address.
vhost_server_email=""

# If the path ends with '.conf', the virtual host will be appended to that file.
# (Ex: /private/etc/apache2/extra/httpd-vhosts.conf)

# If the path is a folder, a new virtual host file will be created.
# (Ex: /private/etc/apache2/extra)"
vhost_conf_path="/private/etc/apache2/extra"

# Is super user authentication needed to access the above path?
# true for yes, false for no.
vhost_sudo=true
