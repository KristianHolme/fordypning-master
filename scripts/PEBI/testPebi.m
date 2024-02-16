clear all
close all
%%
geodata = readGeo('scripts/cutcell/geo/spe11a-V2.geo', 'assignextra', true);
%scale to unit square
for ip = 1:numel(geodata.Point)
    pt = geodata.Point{ip};
    pt(1) = pt(1)/2.8;
    pt(2) = pt(2)/1.2;
    geodata.Point{ip} = pt;
end
clear faults;
data = geodata.V;
for i = 1:size(data,1)
    fault = data{i,2};
    points = curveToPoints(abs(fault), geodata);
    points2D = points(:,1:2);
    faults{i} = points2D;
end
%% Try one segment for each line
data = geodata.Line;
for i = 1:size(data,2)
    fault = data{i};
    points = vertcat(geodata.Point{fault});
    points2D = points(:,1:2);
    faults{i} = points2D;
end
internalLines = setdiff(1:size(geodata.Line, 2), geodata.BoundaryLines);

%%
T = tiledlayout(1,2);
%%

gs = [0.01, 0.01];
pdims = [1, 1];
selection = true(numel(faults),1);
selection([28:32]) = false;
% selection = internalLines(selection);
disp(num2str(selection));
nexttile(1);cla;
segments = find(selection);
for ifl = 1:sum(selection)
    faultsmat = cell2mat(faults(segments(ifl))');
    plot(faultsmat(:,1), faultsmat(:,2), '-o');hold on;
    xlim([0 1]);
    ylim([0 1]);
end
G = compositePebiGrid2D(gs, pdims, 'faceConstraints', faults(selection), ...
    'FCFactor', 0.3, ...
    'circleFactor', 0.6, ...
    'interpolateFC', false);
G = computeGeometry(G);
G = TagbyFacies(G, geodata);
nexttile(2);
newplot;plotCellData(G, G.cells.tag);

%%
G = gmshToMRST('grid-files/spe11a_ref6_alg6.m');
GV = pebi(G);
plotGrid(GV);