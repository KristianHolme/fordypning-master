clear all
close all
%%
mrstModule add ad-core ad-props incomp mrst-gui mpfa mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics nfvm gmsh prosjektOppgave...
    deckformat
%%

gridcase = 'tetRef6';
deckcase = 'RS';
simcase = Simcase('gridcase', gridcase, 'deckcase', deckcase, 'usedeck', true, ...
    'schedulecase', '');

popcells = simcase.getPoPCells;
[cell1Ix, cell2Ix] = simcase.getinjcells;
data = simcase.getCellData('FlowProps.ComponentTotalMass', popcells(1));
data2 = simcase.getCellData('FlowProps.ComponentTotalMass', popcells(2));
data = [data, data2];
labels = ["data1", "data2"];
plotData(labels, data)

%%
gridcase = 'tetRef10';
deckcase = 'RS';
discmethods = {'', 'hybrid-avgmpfa-oo'};
sim1 = Simcase('deckcase', deckcase, 'gridcase', gridcase, ...
    'discmethod', '');
sim2 = Simcase('deckcase', deckcase, 'gridcase', gridcase, ...
    'discmethod', 'hybrid-avgmpfa-oo');
states1 = sim1.getSimData;
states2 = sim2.getSimData;
figure
G = sim1.G;
%%
clf;
plotGrid(G, 'facealpha', 0);view(0,0);
step = 70;
ctm1 = states1{step}.FlowProps.CapillaryPressure{2};
ctm2 = states2{step}.FlowProps.CapillaryPressure{2};
ctmDifference = abs(ctm1-ctm2); 
plotCellData(G, ctmDifference)
colorbar;
axis tight;

%%
simcase = Simcase('deckcase', 'RS', 'gridcase', 'tetRef10', 'usedeck', true, ...
    'discmethod', 'hybrid-avgmpfa-oo');
cellBlocks = getCellblocks(simcase, 'paddingLayers', 1);
simcase.model;

% plotGrid(simcase.G, 'faceAlpha', 0);view(0,0);
% plotGrid(simcase.G, cellBlocks{1});


%% Print number of cells
gridcase = 'tetRef2';

simcase = Simcase('gridcase', gridcase);
disp(['gridcase ', gridcase, 'cells: ', num2str(simcase.G.cells.num)]);

%%
simcase = Simcase('deckcase', 'RS', 'usedeck', true, 'schedulecase', 'simple-std');
% plotCellData(simcase.G, simcase.rock.poro);view(0,0);

%%
geometriesFolder = "C:\Users\holme\OneDrive\Dokumenter\_Studier\Prosjekt\11SPE\src\11thSPE-CSP\geometries";
%%
file = fullfile(geometriesFolder, "spe11a_ref3.m");


G = gmshToMRST(file);
save(fullfile(geometriesFolder, 'spe11a_ref3_grid.mat'), "G");
%%
load(fullfile(geometriesFolder, 'spe11a_ref3_grid.mat'));
rock = createRock11A(G);
%%
plotCellData(G, rock.perm);
%%
[err, errvect, fwerr] = computeOrthError(G, rock, setupTables(G));
%%
figure
plotCellData(G, fwerr);
figure 
plotCellData(G, err);
%% Setup
deck = readEclipseDeck('spe11-utils\deck\CSP11A_RS.DATA');
deck = convertDeckUnits(deck);
refinement = 10;
dim = 3;
G = setupGrid11A('refinement_factor', refinement, 'dim', dim);
rock = setupRock11A(G);
fluid = setupFluid11A('deck', deck);
model = setupModel11A(G, rock, fluid, 'usedeck', true);
schedule = setupSchedule11A(G, rock, 'dim', dim);
% initState = initResSol(G, 1*atm, [1, 0]);
state0 = initStateDeck(model, deck);
nls = getNonLinearSolver(model);
nls.maxTimestepCuts = 20;
%% Setup
injectionTimeStep = 2*minute;
refinement_factor = 3;
settleTimeStep = 2*hour;
[state0, model, schedule, nls] = setup11A('refinement_Factor', refinement_factor, ...
                                          'injectionTimeStep', injectionTimeStep, ...
                                          'settleTimeStep'   , settleTimeStep,...
                                          'dim'              , 3);
%% Full deck sim setup
deckname = 'RSRV';
simcase = Simcase('deckcase', deckname, 'usedeck', true);
%%
solveMultiPhase(simcase, 'resetData', true)
%%
[states, wellsols, reports] = simcase.getSimData;
% states = states{1};
%%
plotToolbar(simcase.G, states);
view(0,0);
%%
simcase = Simcase('SPEcase', 'A', 'gridcase', 'tetRef10', ...
    'fluidcase', 'simple');

%%
solveMultiPhase(simcase, 'usedeck', false);

%%
[states, wellsols, reports] = simcase.getSimData();
%% Simulate
disp('Starting simulation...');
[wellSols, state, report]  = simulateScheduleAD(state0, model, schedule, 'NonLinearSolver', nls);
%%
plotToolbar(G, states, 'field', 's:2', 'startplayback', true)
axis tight; colorbar;
%%
figure
plotGrid(G)
plotGrid(G, [schedule.control(2).W.cells], 'facecolor', 'red')

%%
initpressure = state{1}.pressure;
for i = 1:numel(state)
    state{i}.pressureDiff = state{i}.pressure - initpressure;
end

%%
deckcase = 'RS';
gridcase = 'tetRef10';
schedulecase = 'simple';
simcase = Simcase('deckcase', deckcase,'usedeck', true, 'gridcase', gridcase, ...
    'schedulecase', schedulecase);

%%
[ok, status, time] = solveMultiPhase(simcase, 'resetData', true);

%% Plot perm
plotToolbar(simcase.G, simcase.rock.perm);view(0,0);
%% Plot poro
plotToolbar(simcase.G, simcase.rock.poro);view(0,0);
%% Plot
simcase.plotStates