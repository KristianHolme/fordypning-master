function discname = shortDiscName(discname, varargin)
    opt = struct('uw', false);
    opt = merge_options(opt, varargin{:});
    if contains(discname, 'indicator')
        discname = shortDiscName(replace(discname, 'indicator-', ''), varargin{:});
        discname = ['ind.hyb.-', discname];
        return
    elseif contains(discname, 'leftFaultEntry')
            nameparts = split(discname, '-');
            discname = ['LFE-hybrid-', nameparts{end}];
            return    
    end
    if opt.uw
        if strcmp(discname, '');
            discname = 'SPU';
        elseif strcmp(discname, 'weno')
            discname = 'WENO';
        end
    else

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
    
end