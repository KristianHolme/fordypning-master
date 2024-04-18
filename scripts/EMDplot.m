clear all
close all
%%
SPEcase = 'B';
if strcmp(SPEcase, 'A') 
    xscaling = hour; unit = 'h';
    steps = 720;
    totsteps = 720;
else 
    xscaling = SPEyear;unit='y';
    steps = 301;
    totsteps = 301;
end
%%
deckcase = 'B_ISO_C';


sim1 = Simcase('gridcase', '', 'pdisc', 'hybrid-avgmpfa', 'SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true);
sim2 = Simcase('gridcase', '', 'pdisc', 'hybrid-ntpfa', 'SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true);

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