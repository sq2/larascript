<?php

/**
 * addAlias.php is part of Larascript.
 *
 * addAlias will add a Laravel facade alias to a file with an
 * aliases array. If the alias already exists, it will not be
 * added again.
 */


    /**
     * Argument 1
     * The alias name to be added.
     * Example: "Carbon"
     *
     * @var string
     */
    $name = $argv[1];

    /**
     * Argument 2
     * Path to the facade. Use quotes.
     * Example: "Carbon\Carbon"
     *
     * @var string
     */
    $value = $argv[2];

    /**
     * Argument 3
     * The path and filename of the config file.
     * Example: "app/config/app.php"
     *
     * @var string
     */
    $file = $argv[3];

    /**
     * Read each line of file to an array.
     */
    $lines = file($file);

    $output = '';
    $in_array = false;

    /**
     * Loop over file lines. Quick and dirty.
     */
    foreach ($lines as $line_num => $line) {
        if (! $in_array && strpos($line, "'aliases' =>") !== false) {
            $in_array = true;
        }

        if ($in_array && strpos($line, $value) !== false) {
            break;
        }

        if ($in_array && (strpos($line, ')') !== false || strpos($line, ']') !== false)) {
            $in_array = false;

            $output = rtrim($output);

            $prefix = '';
            $suffix = '';
            if (substr($value, -1) == "'") {
                $suffix = ',';
            } elseif (substr($value, -1) == ',') {
                // Should be single quoted, if ends with comma.
            } else {
                $prefix = "'";
                $suffix = "',";
            }

            $output .= "\n\t\t" . str_pad("'$name'", 18) . '=> ' . $prefix . $value . $suffix . "\n\n";
        }

        $output .= $line;
    }

    /**
     * Save the file.
     */
    if (!$in_array) {
        file_put_contents($file, $output);
    }
