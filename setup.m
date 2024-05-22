configFile = fileread('config.JSON');
config = jsondecode(configFile);
mrstPath('register', 'masterthesis', fullfile(config.repo_folder, 'scripts'))
mrstModule add masterthesis
mrstSettings('set', 'useMEX', true)

%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics masterthesis...
    deckformat gmsh nfvm mpfa msrsb coarsegrid dfm libgeometry...
    upr jutul wellpaths
