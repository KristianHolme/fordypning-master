clear all
close all
%%
mrstModule add incomp mimetic streamlines diagnostics

% Rectangular reservoir with a skew grid.
G = cartGrid([41,20],[2,1]);
makeSkew = @(c) c(:,1) + .4*(1-(c(:,1)-1).^2).*(1-c(:,2));
G.nodes.coords(:,1) = 2*makeSkew(G.nodes.coords);
% G.nodes.coords = twister(G.nodes.coords);
% G.nodes.coords(:,1) = 2*G.nodes.coords(:,1);
G = computeGeometry(G);
G = makeLayeredGrid(G, 0.01);
G = computeGeometry(G);

% Homogeneous reservoir properties
rock = makeRock(G, 100*milli*darcy, .2);
pv   = sum(poreVolume(G,rock));

% Symmetric well pattern
srcCells = findEnclosingCell(G,[2 .975 .005; .5 .025 .005; 3.5 .025 .005]);
src = addSource([], srcCells, [pv; -.5*pv; -.5*pv], 'sat', [1;1;1]);


gravity off
fluid = initSimpleADIFluid('phases', 'W', 'mu', 1*centi*poise, 'rho', 1000);
model = GenericBlackOilModel(G, rock, fluid, 'water', true, 'oil', false, 'gas', false);
state0 = initResSol(G, 0);
schedule = simpleSchedule(1*day, 'src', src);
%%
[wellSols, state, report]  = simulateScheduleAD(state0, model, schedule);

%%
figure
plotToolbar(G, state);
title('TPFA');
    %%
simcase = Simcase('gridcase', 'skewed3D', 'discmethod', 'avgmpfa-oo');
tpfaCells = findCellNeighbors(G, srcCells, 1);
tpfaCells = findCellNeighbors(G, [], 1);
otherCells = setdiff(1:G.cells.num, tpfaCells);
cellblocks{1} = tpfaCells;
cellblocks{2} = otherCells;
hybridModel = getHybridDisc(simcase, model, 'avgmpfa-oo', cellblocks, 'resetAssembly', true);
%%
[wellSolsHy, stateHy, reportHy]  = simulateScheduleAD(state0, hybridModel, schedule);
%%
figure
plotToolbar(G, stateHy);
title('hybrid-avgmpfa-oo');