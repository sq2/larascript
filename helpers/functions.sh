#
# Part of Larascript
# https://github.com/sq2/larascript
#


#-----------------------------------------------------------------------
# STRING & ARRAY FUNCTIONS                                             |
#-----------------------------------------------------------------------

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

# Usage: stringReplace "/" "from" "to" "path/file"
# Usage: stringReplace "@ g s" "from" "to" "path/file"
# Make sure the separator character (first arg) is not found in strings.
# The g added after the separator will replace 'from' throughout file globally.
# The s in the first arg is for sudo.
stringReplace () {
    local sep=${1: -1}
    local global=""

    if [[ $1 == *g* ]]; then
        local global="g"
    fi

    if [[ $1 == *s* ]]; then
        sudo gsed -i "s$sep${2}$sep${3}$sep$global" "$4"
    else
        gsed -i "s$sep${2}$sep${3}$sep$global" "$4"
    fi
}

# Usage: appendAfter "search" "content to add" "path/file"
appendAfter () {
    gsed -i "/${1}/ a\ ${2}" "$3"
}


#-----------------------------------------------------------------------
# FILE & FOLDER OPERATIONS                                             |
#-----------------------------------------------------------------------

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

# If the optional second parameter is 'public', the public path will be
# prepended to the folder path.
# Usage: createFolder "path/to/folder"
createFolder () {
    if [[ $2 == 'public' ]]; then
        local public="$PUBLIC_PATH/"
    fi

    if [[ ! -e "$1" ]]; then
        mkdir "$public$1"
    fi
}

# If the optional second parameter is 'public', the public path will be
# prepended to the folder path.
# Usage: removeFile "path/to/file"
removeFile () {
    if [[ $2 == 'public' ]]; then
        local public="$PUBLIC_PATH/"
    fi

    if [[ -e "$1" ]]; then
        rm "$public$1"
    fi
}

# The source path must be relative from $PROFILE_PATH/src/
# If the optional third parameter is 'public', the public path will be
# prepended to the dest path.
# Usage: copyFile "source/path" "dest/path"
copyFile () {
    if [[ $3 == 'public' ]]; then
        local public="$PUBLIC_PATH/"
    fi

    cp "$PROFILE_PATH/src/$1" "$public$2"
}

# The source path must be relative from $PROFILE_PATH/src/
# If the optional third parameter is 'public', the public path will be
# prepended to the dest path.
# Usage: copyFolder "source/path" "dest/path"
copyFolder () {
    if [[ $3 == 'public' ]]; then
        local public="$PUBLIC_PATH/"
    fi

    cp -R "$PROFILE_PATH/src/$1" "$public$2"
}


#-----------------------------------------------------------------------
# COMMANDS                                                             |
#-----------------------------------------------------------------------

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

# Usage: runAfterComposer "command to run"
runAfterComposer () {
    RUN_AFTER_COMPOSER+=("$1")
}


#-----------------------------------------------------------------------
# PACKAGES                                                             |
#-----------------------------------------------------------------------

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


#-----------------------------------------------------------------------
# CHECKLIST                                                            |
#-----------------------------------------------------------------------

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


#-----------------------------------------------------------------------
# CALL PHP FUNCTIONS                                                   |
#-----------------------------------------------------------------------

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

# The source path must be relative from $PROFILE_PATH/src/
# If the optional third parameter is 'public', the public path will be
# prepended to the dest path.
# Usage: appendFile "source/file" "dest/file"
appendFile () {
    local src="$PROFILE_PATH/src/$1"
    local dst="$2"

    if [[ $3 == 'public' ]]; then
        local dst="$PUBLIC_PATH/$dst"
    fi

    [[ -f "$src" && -f "$dst" ]] || return

    php "$SOURCE_PATH"/helpers/appendFile.php "$src" "$dst"
}
