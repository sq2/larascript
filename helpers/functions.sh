# Usage: relPath from_path to_path
# Get result from $LAST_REL_PATH
relPath () {
    local common path up
    common=${1%/} path=${2%/}/
    while test "${path#"$common"/}" = "$path"; do
        common=${common%/*} up=../$up
    done
    path=$up${path#"$common"/}; path=${path%/};
    printf -v LAST_REL_PATH %s "${path:-.}"
}

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

# Make disabled command available.
disabled () {
    return 0
}

# Test if package should be loaded.
# Usage: packageCheck "path/to/package"
packageCheck () {
    local autoload=false

    while read -r line; do
        if [[ "$line" == "disabled" ]]; then
            return 1
        fi

        if [[ "$line" == "autoload" ]]; then
            autoload=true
        fi
    done < "$1"

    if [[ $autoload == true ]]; then
        return 0
    fi

    return 2
}

# Usage: stringReplace "/" "from" "to" "path/file"
# Usage: stringReplace "@ g s" "from" "to" "path/file"
# Make sure the separator character (first arg) is not found in strings.
# The g added after the separator will replace 'from' throughout file globally.
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

# Usage: addChecklistItem "Something to do."
addChecklistItem () {
    CHECKLIST_ITEMS+=("$1")
}

# Usage: showChecklist
showChecklist () {
    if [[ "$CHECKLIST_ITEMS" ]]; then
        echo
        echo "The following items will need to be handled manually:"
        echo

        for item in "${CHECKLIST_ITEMS[@]}" ; do
            echo "$item"
        done
    fi
}
