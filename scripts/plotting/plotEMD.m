clear all
close all
%%
SPEcase = 'B';
if strcmp(SPEcase, 'A') 
    xscaling = hour; unit = 'h';
    steps = 720;
    totsteps = 720;
else 
    xscaling = speyear;unit='y';
    steps = 301;
    totsteps = 301;
end
%%
deckcase = 'B_ISO_C';


sim1 = Simcase('gridcase', 'struct819x117', 'uwdisc', '', 'tagcase', '', 'SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true);
sim2 = Simcase('gridcase', 'struct819x117', 'uwdisc', 'WENO', 'tagcase', '' , 'SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true);

states1 = sim1.getSimData;
G1 = sim1.G;
states2 = sim2.getSimData;
G2 = sim2.G;

numdata = numelData(states1);
assert(numdata == numelData(states2));
EMD = zeros(numdata, 1);
xdata = cumsum(sim1.schedule.step.val)/xscaling;

tstart = tic();
for i = 2:numdata
    state1 = states1{i}.FlowProps.ComponentTotalMass{2};
    state1 = G1.reductionMatrix*state1;
    state2 = states2{i}.FlowProps.ComponentTotalMass{2};
    state2 = G2.reductionMatrix*state2;
    assert(~all(state1==0));
    assert(~all(state2==0));
    EMD(i) = approxEMD(state1, state2, 'verbose', false);
    % updateProgressBar(numdata, i);
end
t = toc(tstart);
disp(t);

figure;
plot(xdata, EMD);
title(sprintf('%s-%s', sim1.pdisc, sim2.pdisc))

%%
load("/media/kristian/HDD/matlab/output/Benergy.mat")
save("/media/kristian/HDD/matlab/output/Benergy.mat", 'energy', "discnames", 'displaynames');
A = energy;
upperTriangularMask = triu(true(size(A)), 1);

% Replace the upper triangular part with NaN
A(upperTriangularMask) = NaN;
energy = A;
%% Old 
load("/media/kristian/HDD/matlab/output/Benergy.mat")
h = heatmap(energy);
% Remove grid lines
h.GridVisible = 'off';

% Customize the color map to have no color for NaN values
% Define the custom colormap with an extra color for NaNs
customColormap = [jet(256); 1 1 1]; % Jet colormap with white color for NaNs
h.Colormap = jet(256);

% Set the color data to treat NaNs differently
h.MissingDataLabel = '';
h.MissingDataColor = 'none'; % White color for NaNs

h.YDisplayLabels = discnames;
%% Newest, using imagesc
load("/media/kristian/HDD/matlab/output/Benergy.mat")
energy = energy/max(energy, [], "all");
h = imagesc(energy);

cdata = get(gca, 'Children');
% Set the missing data color explicitly to white
set(cdata, 'AlphaData', ~isnan(energy)); % Make NaNs transparent
set(gca, 'XTick', [], 'YTick', []);
colorbar();
colormap(hot);
%% resize, then:
tightfig();

%% save
exportgraphics(gca, './plotsMaster/energyimgHot.eps');

%% Stats
mx = max(energy, [], "all");
energy = energy ./ mx;

md = median(energy(:), 'omitnan');
mn = mean(energy(:), 'omitnan');