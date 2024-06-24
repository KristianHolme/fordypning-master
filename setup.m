configFile = fileread('config.JSON');
config = jsondecode(configFile);
mrstPath('register', 'masterthesis', fullfile(config.repo_folder, 'scripts'))
mrstModule add masterthesis
mrstSettings('set', 'useMEX', true)

%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics masterthesis...
    deckformat gmsh nfvm mpfa msrsb coarsegrid dfm libgeometry...
    upr jutul wellpaths sommer2024

%% Make sure that the grid-files directory exists
% Define the directory path
directoryPath = './grid-files';

% Check if the directory exists
if ~exist(directoryPath, 'dir')
    % If the directory does not exist, create it
    mkdir(directoryPath);
    % fprintf('Directory created: %s\n', directoryPath);
else
    % fprintf('Directory already exists: %s\n', directoryPath);
end

clear all