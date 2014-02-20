# Larascript

Larascript offers a quick, customizable way to setup new Laravel 4.1 ([laravel.com](http://laravel.com)) projects, from the command line. It is meant to be used with MacOS, for local development. Since Larascript is used in a pretty specific environment, it may not be suitable for all situations. Many parts can be slightly modified and used with Linux or Vagrant boxes.

So, why not use Vagrant? You could. My reasons for developing locally are as follows:

- My server environment doesn't change much. I setup everything on my mac and don't have to change it for a long while. Only had to change 3 lines in the Apache configuration file after upgrading to Mavericks. PHP and MySql continued to work.
- During the weekends, I work from home on a different Mac workstation. Working locally makes backup/restore easier. The Vagrant VM's could be saved to an external drive, but it is all or nothing. Not really interested in large backups, when only a few files were changed.
- There are many projects that I work with that have databases. It's nice to be able to access them directly. Also, the actual original DB files are backed up with the my files. This means that no extra MySql setup at home.
- After looking into it, Vagrant won't save me any time. Currently, my system works great. I don't need the latest hotness, just because. Will reevaluate if needs change.
- Switching between many projects as quickly as possible is important to me.
- I work alone.
- It's okay to use my Mac computers this way, and it's okay for you too. (Just in case someone tells you otherwise. #Therapy)

Someone out there can probably argue each of my points, in favor of their process. After investigating other ways, my process works best for me. Ultimately, use whatever makes your life easier. I like working locally. It was taking me quite a while to setup new Laravel projects how I liked them. Then came Larascript, problem solved. If you like the Vagrant way, check out [Vaprobash](https://github.com/fideloper/Vaprobash).

> **Note:** This script is a functional work in progress.


## Features

- A step-by-step interactive Laravel setup process. It asks you questions.
- Setup multiple profiles for different Laravel configurations.
- Changes settings automatically during setup.
- Local environment setup with hostname detection. Production debug is set to false.
- Package configuration files may be added. During the Laravel installation, each will ask if it should be installed, unless autoload is enabled.
- Easy functions for adding service providers and aliases for packages and custom code.
- Simple functions for adding psr-0, psr-4 and items to the classmap array, in composer.json.
- Optional MySql database configuration, if MySql is installed.
- Add common files and folders.
- Public files may be moved to `public_html` or to the root folder (for shared hosting and such), with references automatically updated.
- A place to add customizations, with some commented out sample code.
- An optional Apache virtual host can be created, with `/etc/hosts` domain entries.


## Installation and Usage

### Assumptions

- Familiar with Mac/Linux command line.
- Composer is installed globally and added to the PATH. [Get Composer](http://getcomposer.org)
- PHP cli version 5.4+ is installed and working. [OS X PHP Installer](http://php-osx.liip.ch)
- gsed is installed. `brew install gnu-sed`
- _Optional_ - Install laravel.phar globally for much faster installations. [Install laravel.phar](http://laravel.com/docs/installation#install-laravel) Larascript will now ask to install laravel.phar for you.
- _Optional_ - Local installation of MySql.

### Install Larascript

Let's get Larascript on your Mac. Install it in the folder of your choice. To make things easier to follow, we will assume that Larascript will be installed in `/Sites/larascript` and your first local website project will be located in `/Sites/new_website.dev`.

Use one of the following methods to install Larascript to your Mac workstation.

Install Method 1 - Github Clone. Using the command line, enter the following commands. (May require additional Github setup)
```shell
cd /Sites
git clone git@github.com:sq2/larascript.git
```

Install Method 2 - Curl. Using the command line, enter the following commands.
```shell
cd /Sites
curl -LOk https://github.com/sq2/larascript/archive/master.zip
unzip master.zip
rm master.zip
mv larascript-master larascript
```

### Profiles

Create a profile by duplicating the default profile. This will allow you to customize Larascipt without overwriting your changes, when updating Larascript.
```shell
# Many profiles can be created. Name them as you wish, without spaces. In this case, we will use 'custom'.
cp -R /Sites/larascript/profiles/default /Sites/larascript/profiles/custom
```
Modify `config.sh` and `custom.sh` in the new 'custom' profile. Add any supporting files in the `src` folder. Add packages in the `packages` folder (see below).


### Use Larascript

> **Note:** `larascript.sh` may not be executable when first installed. From its folder, try running `chmod +x larascript.sh`.

To create a new Laravel project based on your Larascript profile, run the following.

```shell
cd /Sites
larascript/larascript.sh
```
Then, answer the questions. If you choose to install Laravel, a project folder (in this case `new_website.dev`) will be created for you.


## Customizations

Just duplicate the `profiles/default` folder and name it. This will be your new profile. Customize `config.sh` and `custom.sh` files to meet your needs.

### Common configurations

Modify `profiles/your_custom_profile/config.sh` file. This file contains variables that can be modified to change Larascript's work flow. There are also some MySql, Virtual Host and Laravel specific settings.

Modify `profiles/your_custom_profile/custom.sh` file. Add any general customizations that are needed. There are examples for common tasks, like the following:

- Adding content or a single line to a file
- Creating files and folders
- Copying files and folders from your profile's src folder
- Adding aliases and service providers
- Adding PSR-0 and PSR-4 pairs to composer.json
- Adding to the classmap in composer.json

To be prompted to load smaller groups of commands, add a custom package.

### Packages

Packages can be used to save and load a group of commands, in a modular way. For each package, Larascript will ask you if you want to load it, unless autoload is enabled. Packages can be available globally by placing them in the `packages` folder, or per profile by placing them in the `profiles/profile_name/packages` folder. Packages bundled with Larascript are located under `profiles/default/packages`. For example, one of the included packages is Clockwork. The filename is `Clockwork_dev.sh`. There are a few commands in this file that Larascript will use to configure this package.

```shell
# Composer command to add this package to the composer.json file as a require-dev item.
composer require --dev --no-update itsgoingd/clockwork:dev-master`

# A Larascript helper function is used to easily add the service provider.
addServiceProvider "Clockwork\Support\Laravel\ClockworkServiceProvider"

# A Larascript helper function is used to easily add the facade alias.
addAlias "Clockwork" "Clockwork\Support\Laravel\Facade"

# A file stored in the Larascript profile src folder will be appended to the end of
# app/start/local.php. These are some optional functions that I liked from
# a laracasts.com video. The $PROFILE_PATH variable holds
# the path to the currently selected customization profile.
cat "$PROFILE_PATH/src/vendor/clockwork.php" >> app/start/local.php
```

#### Autoloading Packages

Add the `autoload` command within a package file, to avoid being prompted to load that package. Place it on a line by itself, preferably near the top of the file.

#### Disabling Packages

Add the `disabled` command within a package file, to skip the prompting and loading of that package. Place it on a line by itself, preferably near the top of the file.


## About the Developer

Hello, my name is Matt. I have been programming in one form or another since 1993. My Twitter handle is @codepl. I code a lot and say very little, so I only have ~~seven~~ nine followers. But, they are all awesome.

Use Larascript as needed. It was uploaded to Github to help the Laravel community. I'm not looking for any job offers or clients. Nor am I writing any books. If you want to contribute code, make a pull request. If you want to contribute money, don't. Please consider donating to @taylorotwell, Laravel's creator. [Gittip](https://www.gittip.com/taylorotwell/) him for future awesomeness.


## Disclaimer / Warranty

This script works well on my Mac workstations. Perhaps you are using a different OS version or have a different configuration. Use at your own risk. There is no warranty. Command line scripts can break your shit. Be careful. :)
