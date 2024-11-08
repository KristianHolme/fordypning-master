function timingname = timingName(name)
    timingname = replace(name, '=', '_');
    timingname = replace(timingname, '-', '_');
    timingname = replace(timingname, '.', '_');
end