
# Append to global.php file
cat "$PROFILE_PATH/src/app/start/global.php" >> app/start/global.php

# Add extra files for easier management. This option depends on
# content in the profile/src/app/start/global.php file.
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
# addServiceProvider "VendorName\Product\ProductServiceProvider"

# Add aliases
echo "Adding facade aliases..."
addAlias "Carbon" "Carbon\Carbon"

# Add psr-0 entries
# echo "Adding psr-0 entries..."
# addToComposer ".autoload.psr-0.Helpers.app/lib"

# Add psr-4 entries
# echo "Adding psr-4 entries..."
# addToComposer ".autoload.psr-4.Helpers\\.app/lib"

# Add to classmap
# echo "Adding classmap entries..."
# addToComposer ".autoload.classmap.app/composers" array
