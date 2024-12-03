function simcases = loadSimcases(gridcases, pdiscs, varargin)
    opt = struct('SPEcase', 'B',...
                 'jutulComp', '');
    opt = merge_options(opt, varargin{:});
    simcases = {};

    for igrid = 1:numel(gridcases)
        gridcase = gridcases{igrid};
        for idisc = 1:numel(pdiscs)
            pdisc = pdiscs{idisc};
            if isempty(opt.jutulComp) && ~strcmp(pdisc, '')
                simcasepdisc = ['hybrid-', pdisc];
            else
                simcasepdisc = pdisc;
            end
            if ~isempty(opt.jutulComp)
                tagcase = 'allcells';
            else
                tagcase = '';
            end
            newsimcase = Simcase('SPEcase', opt.SPEcase, ...
                                      'deckcase', 'B_ISO_C', ...
                                      'usedeck', true, ...
                                      'gridcase', gridcase, ...
                                      'pdisc', simcasepdisc,...
                                      'jutulComp', opt.jutulComp,...
                                      'tagcase', tagcase);
            states = newsimcase.getSimData;
            if numelData(states) > 1
                simcases{end+1} = newsimcase;
            end
        end
    end
end