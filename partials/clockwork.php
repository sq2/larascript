
// Clockwork
function l($val)
{
    return Clockwork::info($val);
}

function start($name, $description)
{
    return Clockwork::startEvent($name, $description);
}

function stop($name)
{
    return Clockwork::endEvent($name);
}
