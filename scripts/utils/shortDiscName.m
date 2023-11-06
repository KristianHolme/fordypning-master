function discname = shortDiscName(discname)
    if isempty(discname)
        discname = 'tpfa';
    else
        discname = replace(discname, 'hybrid-', '');
    end
end