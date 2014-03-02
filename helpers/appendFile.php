<?php

/**
 * appendFile.php is part of Larascript.
 *
 * appendFile will the contents of one file to another, if the content doesn't
 * already exists.
 */


    /**
     * Argument 1
     * Source file.
     *
     * @var string
     */
    $source_file = $argv[1];

    /**
     * Argument 2
     * Dest file.
     *
     * @var string
     */
    $dest_file = $argv[2];

    /**
     * Get file content.
     */
    $source = file_get_contents($source_file);
    $dest = file_get_contents($dest_file);

    /**
     * Determine if content exists.
     */
    $exists = false;

    if (strpos($dest, $source) !== false) {
        $exists = true;
    }

    /**
     * Save the file.
     */
    if (!$exists) {
        file_put_contents($dest_file, $dest . $source);
    }
