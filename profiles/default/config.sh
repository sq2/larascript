# Larascript default profile configuration file.
# Duplicate the profiles/default folder and rename it. Customize as needed.


# Larascript can install Laravel using one of two methods.
#
## Method 1 (composer). Use Composer's create-project command. Composer must be
# installed globally and renamed from composer.phar to composer.
# See https://getcomposer.org/doc/00-intro.md#globally
#
# Method 2 (laravel). The fastest way to install Laravel is to use the Laravel
# installer, laravel.phar. It should be installed globally and renamed
# from laravel.phar to laravel.
# Use the commands below or see http://laravel.com/docs/installation
#
# wget http://laravel.com/laravel.phar
# chmod 755 laravel.phar
# mv laravel.phar /usr/local/bin/laravel
#
# Options: composer or laravel
laravel_installer="composer"


# Local environment host names. Must be an array. Separate each value
# with a space. Ex. hostnames=("MacPro1.local" "Macbook.local"). Default
# value is the hostname for this computer.
hostnames=("$hostname")


# Session lifetime, in minutes
session_lifetime="120"


# Workbench settings
workbench_author_name=""
workbench_email=""


# MySql
mysql_skip=false # Set to true to skip this section
mysql_user="root"
