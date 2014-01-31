
/*
|--------------------------------------------------------------------------
| Require The View Composer File
|--------------------------------------------------------------------------
|
*/

require app_path().'/composers.php';

/*
|--------------------------------------------------------------------------
| Debug Helpers
|--------------------------------------------------------------------------
|
*/

if ( ! function_exists('qd'))
{
    /**
     * Dump database queries.
     *
     * @return void
    */
    function qd($last = false)
    {
        $queries = DB::getQueryLog();

        if ($last) {
            $last_query = end($queries);
            dd($last_query);
        }

        dd($queries);
    }
}
