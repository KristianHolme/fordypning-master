run("/home/shomec/k/kholme/Documents/mrst-bitbucket/mrst-core/startup.m");

names = {'autodiff', ...
         'visualization', ...
         'model-io', ...
         'solvers'};
names = cellfun(@(x) fullfile(ROOTDIR, '..', ['mrst-', x]), names, ...
                    'UniformOutput', false);
mrstPath('addroot', names{:});
clear names

mrstPath register nfvm /home/shomec/k/kholme/Documents/mrst-2023b/modules/nfvm;
mrstPath register test-suite /home/shomec/k/kholme/Documents/mrst-2023b/modules/test-suite
mrstPath register ad-micp /home/shomec/k/kholme/Documents/mrst-2023b/modules/ad-micp
mrstPath register prosjektOppgave /home/shomec/k/kholme/Documents/Prosjektoppgave/src/scripts