# Usage: addServiceProvider "Namespace\To\ServiceProvider"
addServiceProvider () {
    php "$SOURCE_PATH"/helpers/addServiceProvider.php "$1" "$WORK_PATH/${2:-app/config/app.php}"
}

# Usage: addAlias "Alias" "Namespace\To\Facade"
addAlias () {
    php "$SOURCE_PATH"/helpers/addAlias.php "$1" "$2" "$WORK_PATH/${3:-app/config/app.php}"
}

# Usage: addToComposer ".autoload.psr-0.Helpers.app/lib"
addToComposer () {
    php "$SOURCE_PATH"/helpers/addToJson.php "$1" "${2:-key}" "$WORK_PATH/${3:-composer.json}"
}

# Usage: addLine "some string" "path/to/file"
addLine () {
    php "$SOURCE_PATH"/helpers/addLine.php "$1" "$2"
}

# Usage: removeLine "some string" "path/to/file"
removeLine () {
    php "$SOURCE_PATH"/helpers/removeLine.php "$1" "$2"
}

# Usage: commandExists composer
commandExists () {
    type "$1" &> /dev/null
}

# Usage: commandCheck composer
commandCheck () {
    if commandExists "$1" ; then
        return 0
    fi

    echo
    echo "$1 not found. $1 must be installed and in your PATH."
    echo
    echo "Exiting Larascript"
    echo
    exit 1;
}

# Usage: containsElement "value" "array"
containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

# Usage: containsString "needle" "haystack"
containsString () {
    if [[ $2 == *$1* ]]; then
        return 0
    fi

    return 1
}

# Make autoload command available.
autoload () {
    return 0
}

# Test if file should be autoloaded.
# Usage: autoloadCheck "path/to/file"
autoloadCheck () {
    while read -r line; do
        if [[ "$line" == "autoload" ]]; then
            return 0
        fi
    done < "$1"

    return 1
}

# Usage: stringReplace "/" "from" "to" "path/file"
# Usage: stringReplace "@ g s" "from" "to" "path/file"
# Make sure separator character (first arg) is not found in strings. The g
# added after the separator will replace 'from' throughout file globally.
# The s in the first arg is for sudo.
stringReplace () {
    sep=${1: -1}
    global=""

    if [[ $1 == *g* ]]; then
        global="g"
    fi

    if [[ $1 == *s* ]]; then
        sudo gsed -i "s$sep${2}$sep${3}$sep$global" $4
    else
        gsed -i "s$sep${2}$sep${3}$sep$global" $4
    fi
}
