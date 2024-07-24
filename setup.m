configFile = fileread('config.JSON');
config = jsondecode(configFile);
addpath(genpath(fullfile(config.repo_folder, 'scripts')))
addpath(genpath(fullfile(config.repo_folder, 'src')))

mrstSettings('set', 'useMEX', true)

%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics...
    deckformat gmsh nfvm mpfa msrsb coarsegrid dfm libgeometry...
    upr jutul wellpaths sommer2024

%% Make sure that the grid-files directory exists
% Define the directory path
gridPath = './data/grid-files';

% Check if the directory exists
if ~exist(gridPath, 'dir')
    mkdir(gridPath);
end

clear all;