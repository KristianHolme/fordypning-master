clear all
close all
%%
geodata = readGeo('scripts/cutcell/geo/spe11a-faults.geo');
faults = {};
for i = 1:size(geodata.Fault,1)
    fault = geodata.Fault{i,2};
    points = curveToPoints(abs(fault), geodata);
    points2D = points(:,1:2);
    faults{i} = points2D;
end
% loops = cellfun(@(L) curveToPoints(abs(L), geodata), geodata.Loop, UniformOutput=false);


%%
faultsmat = cell2mat(faults(1:7)');
numInclude = size(faultsmat,1);
clf
for ifl = 1:7
    faultsmat = cell2mat(faults(ifl)');
    plot(faultsmat(:,1), faultsmat(:,2), '-o');hold on;
end
%%
gs = [0.03, 0.03];
pdims = [2.8, 1.2];
G = compositePebiGrid2D(gs, pdims, 'faceconstraints', faults([1:11]), ...
    'FCFactor', 0.1, ...
    'circleFactor', 0.7);
%%
clf;plotGrid(G)