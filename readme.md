# Larascript

Larascript offers a quick, customizable way to setup new Laravel 4.1 projects, from the command line. It is meant to be used with MacOS, for local development. Customize `larascript.sh` to meet your needs.

> **Note:** This script is a functional work in progress. Future updates may include configuration files, a better folder structure and a more dynamic way to include customizations.


### Usage

Assuming Larascript is saved to `/Sites/Projects/larascript` and your new local website will be located in `/Sites`, run the following.

```shell
cd /Sites
Projects/larascript/larascript.sh
```
Then, answer the questions. If you choose to install Laravel, a folder will be created for you.


### Assumptions

- Familiar with Mac/Linux command line.
- laravel.phar is installed and added to your path. [Install laravel.phar](http://laravel.com/docs/installation#install-laravel)
- gsed is installed. `brew install gnu-sed`
- PHP cli version is installed and working.
- Composer is installed and added to your path. [Get Composer](http://getcomposer.org)
- Local installation of MySql. _Optional_


### Disclaimer / Warranty

This script works well on my Mac workstations. Perhaps you are using a different OS version or have a different configuration. Use at your own risk. There is no warranty. Command line scripts can break your shit. Be careful. :)
