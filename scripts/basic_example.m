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
GenerateCutCellGrid(130,62)

%%
SPEcase = 'B';
deckcase = 'B_ISO_C';
gridcase = 'horz_ndg_cut_PG_130x62';
pdisc = 'hybrid-avgmpfa';

simcase = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, ...
    'gridcase', gridcase, 'pdisc', pdisc);

[ok, status, time] = solveMultiPhase(simcase);

%% Plot solution
simcase.plotStates();