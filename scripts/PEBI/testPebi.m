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
nx = 130;
ny = 62;
targetsRes = [nx, ny];
gs = pdims ./ targetsRes;

ts = tic();
G = compositePebiGrid2D(gs, pdims, 'faceConstraints', faults(selection), ...
    'FCFactor', 0.44, ...
    'circleFactor', 0.6, ...
    'interpolateFC', false);
G = computeGeometry(G);
G = TagbyFacies(G, geodata);
t = toc(ts);
% nexttile(2);
newplot;plotCellData(G, G.cells.tag);axis tight equal;
fprintf('Done! (%0.2fs)\n', t);
%% Finalize
% 130x62: FCF: 0.44, cF: 0.6
% 460x64: FCF: 0.99, cF: 0.6
% 898
nx = 460;
ny = 64;
G = GeneratePEBIGrid(nx, ny, 'FCFactor', 1.0, 'circleFactor', 0.6, 'save', true, 'bufferVolumeSlice', true);
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