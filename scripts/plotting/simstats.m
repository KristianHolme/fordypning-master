%used to create tables of simulation stats
%%
clear all
close all
%%
mrstVerbose off
%%
% SPEcase = 'B';
% gridcases = {'6tetRef0.4', '5tetRef0.4', '5tetRef1-stretch',...
    % 'semi263x154_0.3', 'struct420x141'};
% gridcases = {'6tetRef0.4'};
% gridcases = {'5tetRef0.4'};
% gridcases = {'5tetRef1-stretch'};
% gridcases = {'semi263x154_0.3'};
% gridcases = {'struct420x141'};

% SPEcase = 'A';
% gridcases = {'6tetRef1', '5tetRef1', 'semi263x154_0.3', 'struct340x150'};
% gridcases = {'6tetRef1'};
% gridcases = {'5tetRef1'};
% gridcases = {'semi263x154_0.3'};
% gridcases = {'struct340x150'};


SPEcase = 'B';
% gridcases = {'horz_ndg_cut_PG_460x64', 'cart_ndg_cut_PG_460x64', 'cPEBI_460x64'};
% gridcases = {'struct819x117', 'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117', '5tetRef0.31'};
% gridcases = {'5tetRef0.31'};
gridcases = {'cPEBI_819x117'};
% gridcases = {'horz_ndg_cut_PG_819x117'};
% gridcases = {'cart_ndg_cut_PG_819x117'};
% gridcases = {'struct819x117'};
% gridcases = {'gq_pb0.19'};
% gridcases = {'horz_ndg_cut_PG_220x110','cPEBI_220x110'};

% SPEcase = 'A'; gridcases = {'5tetRef10'};
pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
% pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-ntpfa'};

tagcase = '';
set(groot, 'defaultLineLineWidth', 2);
%% Disc first
% tabtype = '_discfirst';
% numcases = numel(gridcases) * numel(pdiscs);
% simcases = {};
% for idisc = 1:numel(pdiscs)
%     pdisc = pdiscs{idisc};
%     for igrid = 1:numel(gridcases)
%         gridcase = gridcases{igrid};
%         simcase = Simcase('SPEcase', SPEcase, 'deckcase', 'RS', 'usedeck', true, 'gridcase', gridcase, ...
%                        'pdisc', pdisc, 'tagcase', tagcase);
%         simcases{end+1} = simcase;
%     end
% end
% gridindex = 2;
% discindex = 1;
% cellnumindex = 3;
% totindex = 4;
% meanindex = 5;
%% Grid first
tabtype = '_gridfirst';
numcases = numel(gridcases) * numel(pdiscs);
simcases = {};
for igrid = 1:numel(gridcases)
    gridcase = gridcases{igrid};
    for idisc = 1:numel(pdiscs)
        pdisc = pdiscs{idisc};
        simcase = Simcase('SPEcase', SPEcase, 'deckcase', 'B_ISO_C', 'usedeck', true, 'gridcase', gridcase, ...
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
labels = {};
xscaling = speyear;
xdata = cumsum(simcases{1}.schedule.step.val)/xscaling;
% xdata = xdata(1:steps);
figure;
for isim = 1:numel(simcases)
    simcase = simcases{isim};
    data{cellnumindex, isim} = ['\multirow{4}{*}{', num2str(simcase.G.cells.num) , '}'];
    data{gridindex, isim} = ['\multirow{4}{*}{', displayNameGrid(simcase.gridcase, SPEcase), '}'];
    data{discindex, isim} = shortDiscName(simcase.pdisc);
    [~, ~, reports] = simcase.getSimData;
    steps = numelData(reports);

    labels{end+1} = [shortDiscName(simcase.pdisc)];
    
    cuttingcount = 0;
    totaliterations = 0;
    % ministeps = zeros(steps,1 );
    NlsIts = zeros(steps,1 );
    for s=1:steps
        report = reports{s};
        totaliterations = totaliterations + report.Iterations;
        cuttingcount  = cuttingcount + report.MinistepCuttingCount;
        % ministeps(s) = numel(report.StepReports);
        NlsIts(s) = report.Iterations;

    end
    % plot(ministeps);hold on;
    plot(xdata, cumsum(NlsIts));hold on;
    data{totindex, isim} = totaliterations;
    data{meanindex, isim} = round(totaliterations/steps, 2);
    data{6, isim} = numel(getReportMinisteps(reports(1:steps)));
    data{7, isim} = simcase.getWallTime;
    data{8, isim} = cuttingcount;
end
% plot([20,20], [0,120], 'k');labels{end+1} = 'Injection stop';
grid();
% title('Timestep cuts per control step')
title([displayNameGrid(simcase.gridcase, SPEcase)]);
xlabel('Time [y]');
ylabel('Cumulative nonlinear iterations');
legend(labels, Location="best");
hold off;
exportgraphics(gcf, ['./../plotsMaster/iterations/', SPEcase, '_', displayNameGrid(simcase.gridcase, SPEcase), '.pdf'])
exportgraphics(gcf, ['./../plotsMaster/iterations/', SPEcase, '_', displayNameGrid(simcase.gridcase, SPEcase), '.png'])



%%
%'VariableNames',{'Grid', 'Scheme', 'Iterations', 'Mean its'}
T = table(data');
filename = [SPEcase, tabtype, tagcase, '_iterationtable.tex'];
% writetable(T, fullfile('Misc', filename), FileType="text", Delimiter=';', WriteRowNames=false, WriteVariableNames=false);
%%
% data{7, :} = data{totindex, :} ./ data{6, :};
for i = 1:numel(simcases)
    data{7, i} = round(data{totindex, i} / data{6, i}, 2);
    % data{7, i} = data{7, i};
end
