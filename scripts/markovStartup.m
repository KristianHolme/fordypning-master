disp(['pwd: ', pwd()]);
run(".\..\..\..\mrst-bitbucket\mrst-core\startup.m");

mrstPath register nfvm .\..\..\..\mrst-2023b\modules\nfvm;
mrstPath register test-suite .\..\..\..\mrst-2023b\modules\test-suite
mrstPath register ad-micp .\..\..\..\mrst-2023b\modules\ad-micp;
mrstPath register prosjektOppgave ./