<?php

    /**
     * Argument 1
     * The path and filename of the json file to be changed. Use quotes if path has spaces.
     *
     * @var string
     */
    $file = $argv[1];

    /**
     * Argument 2
     * The json elements to change and its value separated with a dynamic character. Use quotes if has spaces.
     * Example: .autoload.psr-4.Appname.app/lib
     * The first character determines the delimiter, in this case a period. As such, a period separates
     * each level, with the value at the end.
     *
     * @var string
     */
    $input = $argv[2];

    /**
     * Argument 3 - Optional
     * Element type. Currently, 'key' and 'array' types are supported. When a type is not
     * given, 'key' type is used.
     * The key type will add or modify a json key/value pair.
     * The array type will add to a json array.
     *
     * @var string 'key'
     */
    $type = (isset($argv[3])) ? $argv[3] : 'key';

    /**
     * Argument 4 - Future (maybe)
     * Action type. add, remove
     * May only need remove and add by default.
     */

    /**
     * Grab the contents of the specified json file and convert it to an array.
     *
     * @var array
     */
    $json = json_decode(file_get_contents($file), true);

    /**
     * Process the change to the json file.
     */
    array_set($json, $input, $type);

    /**
     * Convert array back to json and save the file.
     */
    file_put_contents($file, json_encode($json, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));


    /**
     * Modified Laravel array_set helper.
     *
     * @param  array $array Array from decoded json file.
     * @param  string $key   Flattened array keys and value with a dynamic separator as the first character.
     *
     * @return array         Modifies input array.
     */
    function array_set(&$array, $key, $type)
    {
        // Convert string to array by the delimiter (first char).
        $keys = explode($key[0], $key);

        // Remove the first item of the array, the delimiter.
        array_shift($keys);

        // Get the value and remove it from the keys.
        $value = array_pop($keys);

        while (count($keys) > 1) {
            $key = array_shift($keys);

            if ( ! isset($array[$key]) || ! is_array($array[$key])) {
                $array[$key] = array();
            }

            $array =& $array[$key];
        }

        if ($type == 'array') {
            // Add to an array.
            $array[array_shift($keys)][] = $value;
        } else {
            // Add or modify a key value.
            $array[array_shift($keys)] = $value;
        }

        return $array;
    }
