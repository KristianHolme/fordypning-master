function discname = shortDiscName(discname)
    if isempty(discname)
        discname = 'tpfa';
    else
        discname = replace(discname, 'hybrid-', '');
    end
    if strcmp(discname, 'avgmpfa')
        discname = 'avgMPFA';
    else
        discname = upper(discname);
    end
end