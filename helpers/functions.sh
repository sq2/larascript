containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

add_service_provider () {
    php "$SOURCE_PATH"/helpers/add_service_provider.php "$1" "$WORK_PATH/${2:-app/config/app.php}"
}

add_alias () {
    php "$SOURCE_PATH"/helpers/add_alias.php "$1" "$2" "$WORK_PATH/${3:-app/config/app.php}"
}

# Usage: add_to_composer ".autoload.psr-0.Helpers.app/lib"
add_to_composer () {
    php "$SOURCE_PATH"/helpers/add_to_json.php "$1" "${2:-key}" "$WORK_PATH/${3:-composer.json}"
}
