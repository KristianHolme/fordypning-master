clear all
close all
%%
SPEcase = 'B';
gridcases = {'struct819x117', 'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117', 'gq_pb0.19', '5tetRef0.31'};
pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
% pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa'};


for ig = 1:numel(gridcases)
    if contains(gridcases{ig}, 'cut')
        numpdiscs = 4;
    else
        numpdiscs = 5;
    end
    makeL1Table(gridcases{ig}, {pdiscs{1:numpdiscs}}, SPEcase)
end
%%
function makeL1Table(gridcase, pdiscs, SPEcase)
endstatenum = 301;
numdiscs = numel(pdiscs);
unit = 1*mega*kilogram;
gridname = displayNameGrid(gridcase, SPEcase);
discnames = cellfun(@shortDiscName, pdiscs, 'UniformOutput', false);

simcase = Simcase('SPEcase', SPEcase, 'gridcase', gridcase, 'pdisc', pdiscs{1}, 'deckcase', 'B_ISO_C', 'usedeck', true);
G = simcase.G;
M = G.reductionMatrix;
Gr = G.reductionGrid;
data = nan(G.cells.num, numdiscs);
% Define reduce function first
for ip = 1:numdiscs
    simcase = Simcase('SPEcase', SPEcase, 'gridcase', gridcase, 'pdisc', pdiscs{ip}, 'deckcase', 'B_ISO_C', 'usedeck', true);
    states = simcase.getSimData;
    endstate = states{endstatenum};
    data(:,ip) = endstate.FlowProps.ComponentTotalMass{2};
    % data(:,ip) = endstate.rs;
    % data(:,ip) = endstate.s(:,2);
end

L1Diffs = nan(numdiscs, numdiscs);
% EMDDiffs = nan(numdiscs, numdiscs);
for i = 1:numdiscs
    L1Diffs(i,i) = 0;
    EMDDiffs(i,i) = 0;
    for j = i+1:numdiscs
        L1Diffs(i,j) = sum( abs( data(:,i) - data(:,j) ) );
        % EMDDiffs(i,j) = approxEMD(reduce(data(:,i), G, M, Gr), reduce(data(:,j), G, M, Gr), 'verbose', false);
    end
end
L1Diffs = L1Diffs'/unit;

C = num2cell(L1Diffs);
for i = 1:numdiscs
    C{i,i} = discnames{i};
    for j = i+1:numdiscs
        C{i,j} = '';
    end
end
%% Make latex table
T = triTab2Latex(C, discnames, gridname);

folder = './../rapport/Tables/L1';
filename = fullfile(folder, [gridname, '.tex']);
% mkdir(folder);
fileID = fopen(filename, 'w');
fprintf(fileID, T);
fclose(fileID);
end

%%
% figure('Name',sprintf('L1, %s', gridname));
% imagesc(L1Diffs);
% colormap(hot);
% colorbar;
% 
% figure('Name',sprintf('EMD, %s', gridname));
% imagesc(EMDDiffs);
% colormap(hot);
% colorbar;
%%
figure('Name',sprintf('L1, %s', 'SPE11B'));
imagesc(L1Diffs);
cdata = get(gca, 'Children');
% Set the missing data color explicitly to white
set(cdata, 'AlphaData', ~isnan(L1Diffs)); % Make NaNs transparent
set(gca, 'XTick', [], 'YTick', []);
colormap(hot);
colorbar;

%%
save('/media/kristian/HDD/matlab/output/L1Diffs.mat', 'L1Diffs', 'discnames', 'displaynames')
%%
function reducedData = reduce(statedata, G, M, Gr)
fulldata = zeros(size(M, 2), 1);
fulldata(G.cells.indexMap) = statedata ./ G.cells.volumes;
reducedData = (M*fulldata) .* Gr.cells.volumes;
end

