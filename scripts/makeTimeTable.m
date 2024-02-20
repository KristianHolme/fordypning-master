clear all 
close all
%%
SPEcase = 'B';
% gridcases = {'cp_pre_cut_130x62', 'pre_cut_130x62', '5tetRef3-stretch', 'struct130x62', ''};%pre_cut_130x62, 5tetRef1.2
% gridcases = {'horz_ndg_cut_PG_130x62', 'horz_pre_cut_PG_130x62', 'cart_ndg_cut_PG_130x62', 'cart_pre_cut_PG_130x62'};
gridcases = {'horz_ndg_cut_PG_460x64', 'cart_ndg_cut_PG_460x64', 'cPEBI_460x64'};
deckcase = 'B_ISO_SMALL'; %B_ISO_SMALL
pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
tagcase = '';%normalRock

numcols = numel(gridcases);
numrows = numel(pdiscs);
data = NaN(numrows, numcols);
decimals = 4;

for ig = 1:numel(gridcases)
    for ip = 1:numel(pdiscs)
        simcase = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcases{ig}, ...
                                    'tagcase', tagcase, ...
                                    'pdisc', pdiscs{ip});
        try
            wallTime = simcase.getWallTime;
        catch
            wallTime = NaN;
        end
        data(ip, ig) = round(wallTime, decimals);
    end
end

T = array2table(data, 'VariableNames', cellfun(@(g)displayNameGrid(g, SPEcase), gridcases, UniformOutput=false), 'RowNames', cellfun(@(p)shortDiscName(p), pdiscs, UniformOutput=false));
%%
table2latex(T, './../rapport/Tables/walltimes_cut-vs-pebi.tex');