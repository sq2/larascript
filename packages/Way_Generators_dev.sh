# Add Way/Generators package to composer.json
composer require --dev --no-update way/generators:dev-master

# Add service provider
add_service_provider "Way\Generators\GeneratorsServiceProvider"
