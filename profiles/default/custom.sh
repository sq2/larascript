
# Append to global.php file
cat "$PROFILE_PATH/src/app/start/global.php" >> app/start/global.php

# Cache settings
gsed -i "s/'prefix' => 'laravel'/'prefix' => '$appname'/" app/config/cache.php

# Add extra files for easier management.
printf "<?php\n\n// View composers" > app/composers.php

# Add view folders
echo "Adding view folders..."
mkdir app/views/layouts
mkdir app/views/auth
mkdir app/views/errors

# Add asset source folders
echo "Adding asset source folders..."
mkdir javascript
mkdir less

# Copy library folders
# echo "Copying library folders..."
# cp -R "$PROFILE_PATH/lib" app/

# Add service providers
# echo "Adding service providers..."
# add_service_provider "VendorName\Product\ProductServiceProvider"

# Add aliases
echo "Adding facade aliases..."
add_alias "Carbon" "Carbon\Carbon"

# Add psr-0 entries
# echo "Adding psr-0 entries..."
# add_to_composer ".autoload.psr-0.Helpers.app/lib"

# Add psr-4 entries
# echo "Adding psr-4 entries..."
# add_to_composer ".autoload.psr-4.Helpers\\.app/lib"

# Add to classmap
# echo "Adding classmap entries..."
# add_to_composer ".autoload.classmap.app/composers" array
