configFile = fileread('config.JSON');
config = jsondecode(configFile);
mrstPath('register', 'prosjektOppgave', fullfile(config.repo_folder, 'scripts'))
mrstModule add prosjektOppgave
mrstSettings('set', 'useMEX', true)
global constant SPEyear;
SPEyear = 60*60*24*365;