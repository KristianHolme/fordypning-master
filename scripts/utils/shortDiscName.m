function discname = shortDiscName(discname, varargin)
    opt = struct('uw', false);
    opt = merge_options(opt, varargin{:});
    if contains(discname, 'indicator')
        if contains(discname, 'layer')
            pattern = 'indicator_\d+';
            replacement = 'ind.';
            discname = regexprep(discname, pattern, replacement);
        end
        nameparts = split(discname, '-');
        nameparts{1} = replace(nameparts{1}, 'indicator', 'ind.');
        nameparts{end} = shortDiscName(nameparts{end});
        discname = join(nameparts, '-');
        discname = discname{1};
        return
    elseif contains(discname, 'leftFaultEntry')
            nameparts = split(discname, '-');
            discname = ['LFE-hybrid-', shortDiscName(nameparts{end})];
            return    
    end
    if opt.uw
        if strcmp(discname, '')
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