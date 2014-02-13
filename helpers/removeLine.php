<?php

/**
 * removeLine.php is part of Larascript.
 *
 * removeLine will remove all instances of a line of text from
 * a file, if it exists.
 */


    /**
     * Argument 1
     * The line to be removed.
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
            continue;
        }

        $output .= $line;
    }

    /**
     * Save the file.
     */
    if ($exists) {
        file_put_contents($file, $output);
    }
