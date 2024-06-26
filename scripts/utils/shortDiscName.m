function discname = shortDiscName(discname, varargin)
    opt = struct('uw', false);
    opt = merge_options(opt, varargin{:});

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