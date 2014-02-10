# Larascript

Larascript offers a quick, customizable way to setup new Laravel 4.1 ([laravel.com](http://laravel.com)) projects, from the command line. It is meant to be used with MacOS, for local development. Since Larascript is used in a pretty specific environment, it may not be suitable for all situations. Many parts can be slightly modified and used with Linux or Vagrant boxes.

> **Note:** This script is a functional work in progress.


### Assumptions

- Familiar with Mac/Linux command line.
- Composer is installed globally and added to the PATH. [Get Composer](http://getcomposer.org)
- PHP cli version 5.4+ is installed and working. [OS X PHP Installer](http://php-osx.liip.ch)
- gsed is installed. `brew install gnu-sed`
- _Optional_ - Install laravel.phar globally for much faster installations. Change setting in profile config. [Install laravel.phar](http://laravel.com/docs/installation#install-laravel)
- _Optional_ - Local installation of MySql.


### Usage

> **Note:** `larascript.sh` may not be executable when first installed. From its folder, try running `chmod +x larascript.sh`.

Assuming Larascript is saved to `/Sites/Projects/larascript` and your new local website will be located in `/Sites`, run the following.

```shell
cd /Sites
Projects/larascript/larascript.sh
```
Then, answer the questions. If you choose to install Laravel, a project folder will be created for you.


## Features

- A step-by-step interactive Laravel setup process. It asks you questions.
- Setup multiple profiles for different Laravel configurations.
- Change settings automatically during setup.
- Local environment setup with hostname detection. Production debug is set to false.
- Package configuration files may be added. During the Laravel installation, each will ask if it should be installed.
- Easily allow the addition of service providers and aliases for packages and custom code.
- Simple functions for adding psr-0, psr-4 and items to the classmap array, in composer.json.
- Optional MySql database configuration, if MySql is installed.
- Add common files and folders.
- Public files may be moved to public_html or to the root (for shared hosting), with references automatically updated.
- A place to add customizations, with some commented out sample code.


## Customizations

Just duplicate the `profiles/default` folder and name it. This will be your new profile. Customize `config.sh` and `custom.sh` files to meet your needs.

### Packages

Create a new file in the `packages` folder for each package Larascript should ask you to install. For example, one of the included packages is Clockwork. The filename is `Clockwork_dev.sh`. There are a few commands in this file that Larascript will use to configure this package.


Composer command to add this package to the composer.json file as a require-dev item.
```
composer require --dev --no-update itsgoingd/clockwork:dev-master`
```

A Larascript helper function is used to easily add the service provider.
```
add_service_provider "Clockwork\Support\Laravel\ClockworkServiceProvider"
```

A Larascript helper function is used to easily add the facade alias.
```
add_alias "Clockwork" "Clockwork\Support\Laravel\Facade"
```

A file stored in the Larascript profile src folder will be appended to the end of app/start/local.php. These are some optional functions that I liked from a [laracasts.com](https://laracasts.com) video. The $PROFILE_PATH variable holds the path to the currently selected customization profile.
```
cat "$PROFILE_PATH/src/vendor/clockwork.php" >> app/start/local.php
```

### About the Developer

Hello, my name is Matt. I have been programming in one form or another since 1993. My Twitter handle is @codepl. I code a lot and say very little, so I only have 7 followers. But, they are all awesome.


### Disclaimer / Warranty

This script works well on my Mac workstations. Perhaps you are using a different OS version or have a different configuration. Use at your own risk. There is no warranty. Command line scripts can break your shit. Be careful. :)
