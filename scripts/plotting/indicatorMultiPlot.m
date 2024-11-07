clear all;
close all;

%% Setup data
getData = @(states, step, G, simcase) simcase.computeStaticIndicator; 
cmap = @(x) [ones(x,1), 1-linspace(0,1,x)', 1-linspace(0,1,x)'];
sumReduce = true; 
force = true;

SPEcase = 'B';
scaling = speyear; unit = 'y';

%% Setup grid cases
gridcases = {'struct819x117', 'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117', 'gq_pb0.19', '5tetRef0.31'};
gridnames = {'C', 'HC', 'CC', 'PEBI', 'QT', 'T'};
filename = 'indicator_comparison';

deckcase = 'B_ISO_C';

plotgrid = false;
saveplot = false;
ColorScale = 'linear';

savefolder = fullfile('./plots/RCS/');

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
    data{j, 1}.statedata = indicator;
    data{j, 1}.injcells = [inj1, inj2];%not needed
    data{j, 1}.G = G;
    data{j, 1}.title = gridnames{j};
end

%% Plotting
data = reshape(data, 3,2)';
%%
multiplot(data, 'savefolder', savefolder, ...
        'savename', filename, ...
        'saveplot', saveplot, 'cmap', cmap(200), 'equal', false, 'plotgrid', plotgrid); 
