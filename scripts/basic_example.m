% Simple example for generating a cut-cell grid and running a single simulation

%% Generate cut-cell grid
generateCutCellGrid(130,62) %horizon-based background grid
%generateCutCellGrid(130,62, 'type', 'cartesian') %cartesian background grid

%%
SPEcase = 'B';
deckcase = 'B_ISO_C';
gridcase = 'horz_ndg_cut_PG_130x62';
%gridcase = 'cart_ndg_cut_PG_130x62'; for cartesian background grid
pdisc = 'hybrid-avgmpfa';
%pdisc = '' %tpfa

simcase = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, ...
    'gridcase', gridcase, 'pdisc', pdisc);

[ok, status, time] = runSimulation(simcase);

%% Plot solution
simcase.plotStates();
