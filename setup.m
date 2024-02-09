configFile = fileread('config.JSON');
config = jsondecode(configFile);
mrstPath('register', 'prosjektOppgave', fullfile(config.repo_folder, 'scripts'))
mrstModule add prosjektOppgave
mrstSettings('set', 'useMEX', true)

%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh nfvm mpfa msrsb coarsegrid dfm libgeometry
