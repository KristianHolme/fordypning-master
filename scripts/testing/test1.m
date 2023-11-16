clear all
close all
%%
mrstModule add ad-core ad-props incomp mrst-gui mpfa mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics nfvm gmsh prosjektOppgave...
    deckformat
%%
[inj1, inj2] = simcase.getinjcells;
[states, ~, ~] = simcase.getSimData;
states{100}.pressure(inj1) 
%%
ABCcase = 'A';
gridcase = '5tetRef10';
simcase = Simcase('SPEcase', ABCcase, 'gridcase', gridcase);
G = simcase.G;
plotGrid(G, 'facealpha', 0);view(0,0);axis tight;axis equal;
rock = simcase.rock;
inj1, inj2 = simcase.getinjcells;
plotGrid(G, [inj1, inj2], 'facecolor', 'red');
%% compute walltime
gridcase = 'semi203x72_0.3';
deckcase = 'RS';
pdisc = '';
uwdisc = 'WENO';
simcase = Simcase('gridcase', gridcase, 'deckcase', deckcase, 'usedeck', false, 'pdisc', pdisc, 'uwdisc' , uwdisc);
% G = simcase.G;
wt = simcase.getWallTime;
wth = wt/3600;


%% SimpleTest linear pressuretest
saveplot = false;
grid = 'semi188x38_0.3';
simcase{1} = Simcase('gridcase', grid, ...
    'pdisc', '');
simcase{2} = Simcase('gridcase', grid, ...
    'pdisc', 'hybrid-avgmpfa');
simcase{3} = Simcase('gridcase', grid, ...
    'pdisc', 'hybrid-ntpfa');
% simcase{4} = Simcase('gridcase', grid, ...
%     'pdisc', 'hybrid-mpfa');
for i = 1:numel(simcase)
    simpleTest(simcase{i}, 'direction', 'tb', ...
        'paddingLayers', -1, 'saveplot', saveplot, ...
        'uniformK', false);
end

% plotCellData(simcase.G, simcase.G.cells.volumes);view(0,0);
%% Find boundary faces
%find side faces
xMin = min(G.nodes.coords(:,1));
xMax = max(G.nodes.coords(:,1));

yMin = min(G.nodes.coords(:,2));
yMax = max(G.nodes.coords(:,2));

slack = 1e-7;
logSideFaces = G.faces.centroids(:,1) < xMin+slack | G.faces.centroids(:,1) > xMax-slack | G.faces.centroids(:,2) < yMin+slack...
    | G.faces.centroids(:,2) > yMax-slack;

logBdryFaces = ( G.faces.neighbors(:,1) == 0 | G.faces.neighbors(:,2) == 0);

logNonSideFaces =  logBdryFaces & ~logSideFaces;
plotFaces(G, find(logNonSideFaces));
view(12,25);
shg;
%% Cellblocks
gridcase = '5tetRef6';
deckcase = 'RS';
simcase = Simcase('gridcase', gridcase, 'deckcase', deckcase, 'usedeck', false, ...
    'schedulecase', '');
getCellblocks(simcase)
simcase.getSimData

%% Plot difference between two cases
gridcase = 'tetRef10';
deckcase = 'RS';
pdiscs = {'', 'hybrid-avgmpfa'};
sim1 = Simcase('deckcase', deckcase, 'gridcase', gridcase, ...
    'pdisc', '');
sim2 = Simcase('deckcase', deckcase, 'gridcase', gridcase, ...
    'pdisc', '', 'tagcase', 'newPVT');
states1 = sim1.getSimData;
states2 = sim2.getSimData;
figure
G = sim1.G;
%% cont. diff plot
clf;
plotGrid(G, 'facealpha', 0);view(0,0);
step = 10;
ctm1 = states1{step}.FlowProps.CapillaryPressure{2};
ctm2 = states2{step}.FlowProps.CapillaryPressure{2};
ctmDifference = abs(ctm1-ctm2); 
plotCellData(G, ctmDifference)
colorbar;
axis tight;

%% Plot Cellblocks
simcase = Simcase('gridcase', 'tetRef10', 'pdisc', 'hybrid-ntpfa');
cellblocks = getCellblocks(simcase);
G = simcase.G;
plotGrid(G, 'facealpha', 0);
plotGrid(G, cellblocks{1}, 'facecolor', 'yellow');
% plotGrid(G, cellblocks{2}, 'facecolor', 'red');
view(0,0);
axis tight;
title('tpfa cells');
%% plot top bc cells
simcase = Simcase('gridcase', 'tetRef2');
bcCells = getbcCells(simcase);
plotGrid(simcase.G, 'facealpha', 0);view(0,0);
plotGrid(simcase.G, bcCells);



%% Plot grid
gridcase = '5tetRef10';
% gridcase = '6tetRef3';
simcase = Simcase('gridcase', gridcase, 'griddim', 2);
figure
plotGrid(simcase.G, 'faceAlpha', 0);view(0,0);axis tight;axis equal;
% plotGrid(simcase.G, cellBlocks{1});


%% Print number of cells
% gridcases = {'5tetRef0.4','5tetRef0.5','5tetRef0.7','5tetRef0.8','5tetRef0.9','5tetRef1', '5tetRef2', '5tetRef3', '6tetRef1','6tetRef2', '6tetRef4',...
%     'struct193x83', 'struct340x150','semi188x38_0.3', 'semi263x154_0.3', 'semi203x72_0.3'};SPEcase = 'A';

gridcases = {'5tetRef0.175','5tetRef0.21', '5tetRef0.3', '5tetRef0.4','5tetRef0.8', '5tetRef2', '5tetRef10'};SPEcase = 'B'; %B grids
% gridcases = {};
% ress = {};

% files = dir('grid-files/spe11b_struct*');
% for k = 1:length(files)
%     filename = files(k).name;
%     % Regular expression to find the pattern 'structAxB' where A and B are numbers
%     tokens = regexp(filename, 'spe11b_struct(\d+x\d+).m', 'tokens');
%     if ~isempty(tokens)
%         % tokens{1}{1} contains the 'AxB' part
%         disp(tokens{1}{1});
%         ress{end+1} = tokens{1}{1};
%     end
% end
% ress = {'336x141','420x122','420x141','840x100','840x110','840x120',...
% '840x122','840x141','84x12'};SPEcase = 'B';

% gridcases = cellfun(@(x) ['struct' x], ress, 'UniformOutput', false);
for i = 1:numel(gridcases)
    gridcase = gridcases{i};
    simcase = Simcase('SPEcase', SPEcase, 'gridcase', gridcase);
    disp(['gridcase ', gridcase, 'cells: ', num2str(simcase.G.cells.num)]);
    % plotCellData(simcase.G, simcase.rock.perm(:,1)), view(0,0);
    % clf
end
%%
initpressure = state{1}.pressure;
for i = 1:numel(state)
    state{i}.pressureDiff = state{i}.pressure - initpressure;
end
%% Plot perm
SPEcase = 'B';
gridcase = '5tetRef0.1';%193x83
screenSize = get(0, 'ScreenSize');
figWidth = screenSize(3)*0.7;
figHeight = screenSize(4)*0.7;
simcase = Simcase('SPEcase', SPEcase, 'gridcase', gridcase, 'usedeck', true, 'deckcase', 'RS');
figure('Position', [screenSize(3)*0.1 screenSize(4)*0.1 figWidth figHeight]);
plotToolbar(simcase.G, simcase.rock.perm);view(0,0);
%% Plot poro
plotToolbar(simcase.G, simcase.rock.poro);view(0,0);
%% Plot
simcase.plotStates