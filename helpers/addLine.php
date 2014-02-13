<?php

/**
 * addLine.php is part of Larascript.
 *
 * addLine will add a line of text to a file, if it doesn't
 * already exists.
 */


    /**
     * Argument 1
     * The line to be added.
     *
     * @var string
     */
    $value = $argv[1];

    /**
     * Argument 2
     * The path and filename of the file.
     * Example: "app/config/app.php"
     *
     * @var string
     */
    $file = $argv[2];

    /**
     * Read each line of file to an array.
     */
    $lines = file($file);

    $exists = false;
    $output = '';

    /**
     * Loop over file lines to determine if value exists.
     */
    foreach ($lines as $line_num => $line) {
        if (trim($line) == trim($value)) {
            $exists = true;
            break;
        }

        $output .= $line;
    }

    /**
     * Save the file.
     */
    if (!$exists) {
        $output = rtrim($output);
        $output .= "\n" . $value;

        file_put_contents($file, $output);
    }
