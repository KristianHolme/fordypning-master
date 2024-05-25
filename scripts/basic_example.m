% Simple example for generating a cut-cell grid and running a single simulation
%% Make sure that the grid-files directory exists
% Define the directory path
directoryPath = './grid-files';

% Check if the directory exists
if ~exist(directoryPath, 'dir')
    % If the directory does not exist, create it
    mkdir(directoryPath);
    fprintf('Directory created: %s\n', directoryPath);
else
    fprintf('Directory already exists: %s\n', directoryPath);
end
%% Generate cut-cell grid
GenerateCutCellGrid(130,62) %horizon-based background grid
%GenerateCutCellGrid(130,62, 'type', 'cartesian') %cartesian background grid

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
