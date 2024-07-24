function simcases = getSimcasesBatch(varargin)
opt = struct( ...
    'SPEcase', 'B',...
    'deckcases', {'B_ISO_C'}, ...
    'gridcases', {''}, ...
    'pdiscs', {''}, ...
    'uwdiscs', {''},...
    'tagcase', '',...
    'schedulecases', {''},...
    'jutul', false,...
    'jutulThermal', false);
opt = merge_options(opt, varargin{:});

deckcases = opt.deckcases;
gridcases = opt.gridcases;
pdiscs = opt.pdiscs;
schedulecases = opt.schedulecases;
tagcase = opt.tagcase;
uwdiscs = opt.uwdiscs;
Jutul = opt.jutul;
jutulThermal = opt.jutulThermal;


simcases = {};

for ideck = 1:numel(deckcases)
    deckcase = opt.deckcases{i};
    for igrid = 1:numel(gridcases)
        gridcase = gridcases{igrid};
        for ischedule = 1:numel(schedulecases)
            schedulecase = schedulecases{ischedule};
            for ipdisc = 1:numel(pdiscs)
                pdisc = pdiscs{ipdisc};
                for iuwdisc = 1:numel(uwdiscs)
                    uwdisc = uwdiscs{iuwdisc};
                    simcases{end+1} = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                                    'schedulecase', schedulecase, 'tagcase', tagcase, ...
                                    'pdisc', pdisc, 'uwdisc', uwdisc, 'jutul', Jutul, 'jutulThermal', jutulThermal);

                end
            end
        end

    end
end

end