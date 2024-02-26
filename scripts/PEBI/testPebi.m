clear all
close all
%%
geodata = readGeo('scripts/cutcell/geo/spe11a-V2.geo', 'assignextra', true);
%scale to unit square
% for ip = 1:numel(geodata.Point)
%     pt = geodata.Point{ip};
%     pt(1) = pt(1)/2.8;
%     pt(2) = pt(2)/1.2;
%     geodata.Point{ip} = pt;
% end
clear faults;
data = geodata.V;
for i = 1:size(data,1)
    fault = data{i,2};
    points = curveToPoints(abs(fault), geodata);
    points2D = points(:,1:2);
    faults{i} = points2D;
end
% %% Extend slices?
% extendFactor = 0.01;
% for i = 1:numel(faults)
%     fault = faults{i};
%     startdir = fault(2,:) - fault(1,:);
%     startdir = startdir/norm(startdir);
%     enddir = fault(end,:) - fault(end-1, :);
%     enddir = enddir/norm(enddir);
% 
%     newstart = fault(1,:) - startdir*extendFactor;
%     newend = fault(end, :) + enddir*extendFactor;
%     fault = [newstart;fault;newend];
%     faults{i} = fault;
% end

%%
% T = tiledlayout(1,2);
%% Composite, find params
selection = true(numel(faults),1);
selection([]) = false;
% selection = internalLines(selection);
disp('Generating...');
% nexttile(1);cla;
% segments = find(selection);
% for ifl = 1:sum(selection)
%     faultsmat = cell2mat(faults(segments(ifl))');
%     plot(faultsmat(:,1), faultsmat(:,2), '-o');hold on;
%     xlim([0 1]);
%     ylim([0 1]);
% end
pdims = [2.8, 1.2];
nx = 898;
ny = 120;
targetsRes = [nx, ny];
gs = pdims ./ targetsRes;

ts = tic();
[G, Pts] = compositePebiGrid2D(gs, pdims, 'faceConstraints', faults(selection), ...
    'FCFactor', 1.0, ...
    'circleFactor', 0.6, ...
    'interpolateFC', false);
G = computeGeometry(G);
G = TagbyFacies(G, geodata);
t = toc(ts);
% nexttile(2);
newplot;plotCellData(G, G.cells.tag);axis tight equal;
fprintf('Done! (%0.2fs)\n', t);
%% Check Voronoi-property
N      = G.faces.neighbors;
intInx = all(N ~= 0, 2);
faceCenters = G.faces.centroids;
% cellFaceCenters = faceCenters(G.cells.faces(:,1),:);

F = faceCenters(intInx, :);
A = G.cells.centroids(G.faces.neighbors(intInx,1),:);
B = G.cells.centroids(G.faces.neighbors(intInx,2),:);
N = G.faces.normals(intInx,:);

t = dot(F-A, N, 2) ./ dot(B-A, N, 2);

faceCenters(intInx,:) = A + ((B-A) .* t);

cellFaceCenters = faceCenters(G.cells.faces(:,1),:);
intFaces = faceCenters(intInx,:);
FacescOld = G.faces.centroids;


c2c = (B-A)./sqrt(sum((B-A).^2, 2));
sA = Pts(G.faces.neighbors(intInx, 1),:);
sB = Pts(G.faces.neighbors(intInx, 2),:);
s2s = (sB-sA)./sqrt(sum((sB-sA).^2, 2));
normals = G.faces.normals(intInx,:) ./ G.faces.areas(intInx);

prod = sum(c2c .* normals, 2);
theta = acosd(prod);
sprod = sum(s2s .* normals, 2);
stheta = acosd(sprod);
[~, sthetasort] = sort(stheta, 'descend');

intfaces = find(intInx);
faceselection = intfaces(sthetasort(1:1));
cells = setdiff(unique(reshape(G.faces.neighbors(faceselection,:), [], 1)), 0);


plotGrid(G, 'facecolor', 'none');hold on;
h1 = plot(faceCenters(faceselection,1), faceCenters(faceselection,2), 'ro', 'LineWidth', 0.1);
h2 = plot(FacescOld(faceselection,1), FacescOld(faceselection,2), 'bo', 'LineWidth', 0.1);
h3 = plot(G.cells.centroids(cells,1), G.cells.centroids(cells,2), 'ko', 'LineWidth', 0.1);

sitePlotData = [];
for iface = 1:numel(faceselection)
    sitePlotData = [sitePlotData;Pts(G.faces.neighbors(faceselection(iface),:),:);NaN,NaN];
end
h4 = plot(sitePlotData(:,1), sitePlotData(:,2), 'm-o', 'LineWidth', 0.1);
% h4 = plot(NaN, NaN, 'm-o', 'LineWidth', 0.1);
% set(gca, 'xlim', [1.46, 1.48], 'ylim', [0.675, 0.7])
axis equal;
legend([h1, h2, h3, h4], 'Cell2cell-faceplane intersection', 'face centroid', 'cell centroid', 'voronoi sites');
%% Finalize
% 130x62: FCF: 0.53, cF: 0.6
% 220x110: FCF: 0.94, cF: 0.6
% 460x64: FCF: 1.0, cF: 0.6
% 898x120: FCF: 1.0, cF: 0.6, useMrstPebi false
nx = 130;
ny = 62;
[G, G2D, Pts] = GeneratePEBIGrid(nx, ny, 'FCFactor', 0.53, 'circleFactor', 0.6, 'save', true, ...
    'bufferVolumeSlice', true, ...
    'useMrstPebi', false, ...
    'earlyReturn', false);
%%
plotCellData(G2D, G2D.cells.tag);axis tight equal;
%%
histogram(log10(G.cells.volumes));
title(sprintf('PEBI grid (%dx%d)', nx, ny));
xlabel('Log10(cell volumes)');
ylabel('Frequency');
%% non-composite

selection = true(numel(faults),1);
selection([]) = true;
disp(num2str(sum(selection)));
pdims = [2.8, 1.2];
targetsCells = 130*62;
gs = sqrt( 4*prod(pdims)/(pi*targetsCells) );


G = pebiGrid2D(gs, pdims, 'faceConstraints', faults(selection), ...
    'FCFactor', 0.3, ...
    'circleFactor', 0.9, ...
    'interpolateFC', false);
G = computeGeometry(G);
G = TagbyFacies(G, geodata);
% nexttile(2);
newplot;plotCellData(G, G.cells.tag);axis tight equal;