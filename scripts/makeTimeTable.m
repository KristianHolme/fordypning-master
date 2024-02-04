clear all 
close all
%%
SPEcase = 'B';
% gridcases = {'cp_pre_cut_130x62', 'pre_cut_130x62', '5tetRef3-stretch', 'struct130x62', ''};%pre_cut_130x62, 5tetRef1.2
gridcases = {'', 'struct130x62', 'horz_pre_cut_PG_130x62', 'cart_pre_cut_PG_130x62'};
deckcases = {'B_ISO_SMALL'}; %B_ISO_SMALL
pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa'};
tagcase = '';%normalRock

numcols = numel(gridcases);
numrows = numel(pdiscs);
data = zeros(numrows, numcols);

for ig = 1:numel(gridcases)
    for ip = 1:numel(pdiscs)
        simcase = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcases{ig}, ...
                                    'tagcase', tagcase, ...
                                    'pdisc', pdiscs{ip});
        data(ip, ig) = simcase.getWallTime;
    end
end

T = array2table(data, 'VariableNames', cellfun(@(g)displayNameGrid(g, SPEcase), gridcases, UniformOutput=false), 'RowNames', cellfun(@(p)shortDiscName(p), pdiscs, UniformOutput=false));
