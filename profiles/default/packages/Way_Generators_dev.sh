# Uncomment the following line to autoload this package.
#autoload

# Add Way/Generators package to composer.json
composer require --dev --no-update way/generators:dev-master

# Add service provider
addServiceProvider "Way\Generators\GeneratorsServiceProvider"
