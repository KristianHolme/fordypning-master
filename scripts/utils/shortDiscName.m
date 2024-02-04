function discname = shortDiscName(discname)
    if contains(discname, 'cc')
        if contains(discname, 'loc')
            discname = 'TPFA-cc-loc';
        else
            discname = 'TPFA-cc';
        end
        return
    end
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