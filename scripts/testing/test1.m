clear all
close all
%%
mrstModule add ad-core ad-props incomp mrst-gui mpfa mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics nfvm gmsh prosjektOppgave...
    deckformat
%% SimpleTest
saveplot = false;
grid = 'semi188x38_0.3';
simcase{1} = Simcase('gridcase', grid, ...
    'discmethod', '');
simcase{2} = Simcase('gridcase', grid, ...
    'discmethod', 'hybrid-avgmpfa-oo');
simcase{3} = Simcase('gridcase', grid, ...
    'discmethod', 'hybrid-ntpfa-oo');
% simcase{4} = Simcase('gridcase', grid, ...
%     'discmethod', 'hybrid-mpfa-oo');
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
gridcase = 'tetRef6';
deckcase = 'RS';
simcase = Simcase('gridcase', gridcase, 'deckcase', deckcase, 'usedeck', false, ...
    'schedulecase', '');
getCellblocks(simcase)


%% Plot difference between two cases
gridcase = 'tetRef10';
deckcase = 'RS';
discmethods = {'', 'hybrid-avgmpfa-oo'};
sim1 = Simcase('deckcase', deckcase, 'gridcase', gridcase, ...
    'discmethod', '');
sim2 = Simcase('deckcase', deckcase, 'gridcase', gridcase, ...
    'discmethod', '', 'tagcase', 'newPVT');
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
simcase = Simcase('gridcase', 'tetRef10', 'discmethod', 'hybrid-ntpfa-oo');
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
gridcase = 'semi203x72_0.3';
% gridcase = '6tetRef3';
simcase = Simcase('gridcase', gridcase);
figure
plotGrid(simcase.G, 'faceAlpha', 0);view(0,0);axis tight;axis equal;
% plotGrid(simcase.G, cellBlocks{1});


%% Print number of cells
gridcases = {'5tetRef10', '5tetRef8', '5tetRef6', '5tetRef4','5tetRef2', '5tetRef1',...
    'struct220x90', 'struct340x150','semi188x38_0.3', 'semi263x154_0.3', 'semi203x72_0.3'};
for i = 1:numel(gridcases)
    gridcase = gridcases{i};
    simcase = Simcase('gridcase', gridcase);
    disp(['gridcase ', gridcase, 'cells: ', num2str(simcase.G.cells.num)]);
end
%%
initpressure = state{1}.pressure;
for i = 1:numel(state)
    state{i}.pressureDiff = state{i}.pressure - initpressure;
end
%% Plot perm
figure
plotToolbar(simcase.G, simcase.rock.perm);view(0,0);
%% Plot poro
plotToolbar(simcase.G, simcase.rock.poro);view(0,0);
%% Plot
simcase.plotStates