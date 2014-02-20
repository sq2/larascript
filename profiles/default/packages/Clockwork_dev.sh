# Uncomment the following line to autoload this package.
#autoload
#disabled

# Add Clockwork package to composer.json. Recommended by Jeffrey Way at laracasts.com.
composer require --dev --no-update itsgoingd/clockwork:dev-master

# Add service provider
addServiceProvider "Clockwork\Support\Laravel\ClockworkServiceProvider"

# Add facade alias
addAlias "Clockwork" "Clockwork\Support\Laravel\Facade"

# Append to local.php file
cat "$PROFILE_PATH/src/vendor/clockwork.php" >> app/start/local.php
