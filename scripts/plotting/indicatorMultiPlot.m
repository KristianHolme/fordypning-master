clear all;
close all;


%% Setup data
getData = @(states, step, G, simcase) simcase.computeStaticIndicator; 
cmap = @(x) [ones(x,1), 1-linspace(0,1,x)', 1-linspace(0,1,x)'];
cmap = cmap(256);
% cmap = "seismic";
sumReduce = true; 
force = true;

SPEcase = 'B';
scaling = speyear; unit = 'y';

%% Setup grid cases
gridcases = {'struct819x117', 'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117', 'gq_pb0.19', '5tetRef0.31'};
gridnames = {'C', 'HC', 'CC', 'PEBI', 'QT', 'T'};
filename = 'indicator_sqrt';

deckcase = 'B_ISO_C';

plotgrid = false;
saveplot = true;

savefolder = fullfile('./plots/RSC/', 'indicatorComparison');

%% Setup dimensions
numGrids = numel(gridcases);

%% Loading data
data = cell(numGrids, 1);
for j = 1:numGrids
    gridcase = gridcases{j};
    simcase = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, ...
                    'gridcase', gridcase);
    
    G = simcase.G;
    indicator = simcase.computeStaticIndicator;
    [inj1, inj2] = simcase.getinjcells;
    % Count number of zeros in indicator
    numZeros = sum(indicator == 0);
    fprintf('Grid %s: Number of zeros = %d (%.2f%%)\n', gridnames{j}, numZeros, 100*numZeros/numel(indicator));
    % Print min and max of indicator
    fprintf('Grid %s: Min = %.2e, Max = %.2e\n', gridnames{j}, min(indicator), max(indicator));
    data{j, 1}.statedata = sqrt(indicator);
    data{j, 1}.injcells = [inj1, inj2];%not needed
    data{j, 1}.G = G;
    data{j, 1}.title = gridnames{j};
end
%%
% threshold = 8e-22;
% for j = 1:numGrids
%     indicator = data{j, 1}.statedata;
%     indicator(indicator < threshold) = threshold;
%     data{j, 1}.statedata = log10(indicator);
% end

%% Plotting
data = reshape(data, 3,2)';
%%
multiplot(data, 'savefolder', savefolder, ...
        'savename', filename, ...
        'saveplot', saveplot, 'cmap', cmap, ...
        'equal', false, 'plotgrid', plotgrid, ...
        'facelines', true, ...
        'graybackground', true); 
