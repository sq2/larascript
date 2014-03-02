#
# Part of Larascript
# https://github.com/sq2/larascript
#


#-----------------------------------------------------------------------
# FOLDERS                                                              |
#-----------------------------------------------------------------------

# Add asset source folders.
# echo "Adding asset source folders..."
# createFolder javascript
# createFolder less
# createFolder scss

# Add asset folders.
# echo "Adding asset folders..."
# createFolder "$PUBLIC_PATH/img"
# createFolder "$PUBLIC_PATH/includes"

# Add view folders.
# echo "Adding view folders..."
# createFolder app/views/layouts
# createFolder app/views/auth
# createFolder app/views/errors


#-----------------------------------------------------------------------
# FILES                                                                |
#-----------------------------------------------------------------------

echo "Copying customized files..."

# Append to global.php file.
appendFile "$PROFILE_PATH/src/app/start/global.php" app/start/global.php

# Create a dedicated view composers file.
# Note: This option depends on content in the
# profile/src/app/start/global.php file that will be copied above.
printf "<?php\n\n// View composers" > app/composers.php


#-----------------------------------------------------------------------
# REMOVE DEFAULTS                                                      |
#-----------------------------------------------------------------------

# echo "Removing defaults..."

# Remove default view.
# removeFile app/views/hello.php

# Remove default controller.
# removeFile app/controllers/HomeController.php


#-----------------------------------------------------------------------
# LIBRARIES                                                            |
#-----------------------------------------------------------------------

# Copy library folders.
# echo "Copying library folders..."
# cp -R "$PROFILE_PATH/lib" app/


#-----------------------------------------------------------------------
# SERVICE PROVIDERS                                                    |
#-----------------------------------------------------------------------

# Add service providers.
# echo "Adding service providers..."
# addServiceProvider "VendorName\Product\ProductServiceProvider"


#-----------------------------------------------------------------------
# ALIASES                                                              |
#-----------------------------------------------------------------------

# Add aliases.
echo "Adding facade aliases..."
addAlias "Carbon" "Carbon\Carbon"


#-----------------------------------------------------------------------
# COMPOSER.JSON                                                        |
#-----------------------------------------------------------------------

# Add psr-0 entries.
# echo "Adding psr-0 entries..."
# addToComposer ".autoload.psr-0.Helpers.app/lib"

# Add psr-4 entries.
# echo "Adding psr-4 entries..."
# addToComposer ".autoload.psr-4.Helpers\\.app/lib"

# Add to classmap.
# echo "Adding classmap entries..."
# addToComposer ".autoload.classmap.app/composers" array


#-----------------------------------------------------------------------
# IGNORES                                                              |
#-----------------------------------------------------------------------

# Ignore more stuff.
echo "Adding to .gitignore..."
addLine "error_log" .gitignore
# addLine "$PUBLIC_DIR/uploads" .gitignore
