clear all
close all
%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh nfvm mpfa Jutul
mrstVerbose off
%%
SPEcase = 'B';
gridcases = {'6tetRef0.4', '5tetRef0.4', '5tetRef1-stretch',...
    'semi263x154_0.3', 'struct420x141'};
SPEcase = 'A';
gridcases = {};

pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-mpfa', 'hybrid-ntpfa'};

tagcase = '';
%% Disc first
tabtype = '_discfirst';
numcases = numel(gridcases) * numel(pdiscs);
simcases = {};
for idisc = 1:numel(pdiscs)
    pdisc = pdiscs{idisc};
    for igrid = 1:numel(gridcases)
        gridcase = gridcases{igrid};
        simcase = Simcase('SPEcase', SPEcase, 'deckcase', 'RS', 'usedeck', true, 'gridcase', gridcase, ...
                       'pdisc', pdisc, 'tagcase', tagcase);
        simcases{end+1} = simcase;
    end
end
gridindex = 2;
discindex = 1;
cellnumindex = 3;
totindex = 4;
meanindex = 5;
%% Grid first
tabtype = '_gridfirst';
numcases = numel(gridcases) * numel(pdiscs);
simcases = {};
for igrid = 1:numel(gridcases)
    gridcase = gridcases{igrid};
    for idisc = 1:numel(pdiscs)
        pdisc = pdiscs{idisc};
        simcase = Simcase('SPEcase', SPEcase, 'deckcase', 'RS', 'usedeck', true, 'gridcase', gridcase, ...
                       'pdisc', pdisc, 'tagcase', tagcase);
        simcases{end+1} = simcase;
    end
end
gridindex = 1;
discindex = 3;
cellnumindex = 2;
totindex = 4;
meanindex = 5;
%% get data
data = cell(6, numel(simcases));
for isim = 1:numel(simcases)
    simcase = simcases{isim};
    data{cellnumindex, isim} = ['\multirow{4}{*}{', num2str(simcase.G.cells.num) , '}'];
    data{gridindex, isim} = ['\multirow{4}{*}{', displayNameGrid(simcase.gridcase, SPEcase), '}'];
    data{discindex, isim} = shortDiscName(simcase.pdisc);
    [~, ~, reports] = simcase.getSimData;
    steps = numelData(reports);
    
    totaliterations = 0;
    for s=1:steps
        report = reports{s};
        totaliterations = totaliterations + report.Iterations;
    end
    data{totindex, isim} = totaliterations;
    data{meanindex, isim} = round(totaliterations/steps, 2);
    data{6, isim} = numel(getReportMinisteps(reports(1:steps)));
    
end
%%
%'VariableNames',{'Grid', 'Scheme', 'Iterations', 'Mean its'}
T = table(data');
filename = [SPEcase, tabtype, '_iterationtable.tex'];
writetable(T, fullfile('Misc', filename), FileType="text", Delimiter=';', WriteRowNames=false, WriteVariableNames=false);
%%

