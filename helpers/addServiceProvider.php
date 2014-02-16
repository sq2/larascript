<?php

    /**
     * Argument 1
     * The service provider value to be added. Must use quotes.
     * Example: "Way\Generators\GeneratorsServiceProvider"
     *
     * @var string
     */
    $value = $argv[1];

    /**
     * Argument 2
     * The path and filename of the config file. Use quotes if path has spaces.
     * Example: app/config/app.php
     *
     * @var string
     */
    $file = $argv[2];

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
        if (! $in_array && strpos($line, "'providers' =>") !== false) {
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

            $output .= "\n\t\t" . $prefix . $value . $suffix . "\n\n";
        }

        $output .= $line;
    }

    /**
     * Save the file.
     */
    if (!$in_array) {
        file_put_contents($file, $output);
    }
