# Set paths
WORK_PATH=$(pwd)

# Get hostname
hostname=$(hostname)

# Include functions
. "$SOURCE_PATH"/helpers/functions.sh

# Make sure required commands are available.
commandCheck composer
commandCheck gsed
commandCheck php
