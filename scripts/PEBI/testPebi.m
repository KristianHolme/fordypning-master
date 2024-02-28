clear all
close all
%% Find smallest good resolution
startny = 60;
warning('off', 'all');
for dny = 1:100
    ny = startny + dny;
    nx = 7*ny;
    try
        GeneratePEBIGrid(nx, ny, 'save', false, 'earlyReturn', true, 'verbose', false);
        fprintf('Success for %dx%d!\n', nx, ny);
        break
    catch
        dispif(mod(dny,10)==0, 'Failed upto %dx%d\n', nx, ny);
        continue
    end
end
warning('on', 'all');
%% Correct wrong depth
% Set the folder path and file type
folderPath = 'grid-files/PEBI'; % Replace with your folder path
fileType = '*.mat'; % Replace with your file type, e.g., '*.txt', '*.csv'

% Get a list of all files in the folder with the specified file type
files = dir(fullfile(folderPath, fileType));

% Loop through each file
for k = 1:length(files)
    % Full path to the file
    fullFileName = fullfile(folderPath, files(k).name);
    
    % Load the file
    % Assuming the file is a .mat file. Modify this part according to your file type.
    G = load(fullFileName).G;

    backnodes = G.nodes.coords(:,2) > 0;
    iswrong = any(G.nodes.coords(backnodes, 2) > 1.001);
    G.nodes.coords(backnodes, 2) = 1;

    G = mcomputeGeometry(G);
    
    
    % Save the file with the same name
    save(fullFileName, 'G'); % For .mat files
    % If it's a different file type, use the appropriate save/write function
end

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
% h1 = plot(faceCenters(faceselection,1), faceCenters(faceselection,2), 'ro', 'LineWidth', 0.1);
h2 = plot(FacescOld(faceselection,1), FacescOld(faceselection,2), 'bo', 'LineWidth', 0.1);
h3 = plot(G.cells.centroids(cells,1), G.cells.centroids(cells,2), 'ko', 'LineWidth', 0.1);

sitePlotData = [];
for iface = 1:numel(faceselection)
    sitePlotData = [sitePlotData;Pts(G.faces.neighbors(faceselection(iface),:),:);NaN,NaN];
end
% h4 = plot(sitePlotData(:,1), sitePlotData(:,2), 'm-o', 'LineWidth', 0.1);
% h4 = plot(NaN, NaN, 'm-o', 'LineWidth', 0.1);
% set(gca, 'xlim', [1.46, 1.48], 'ylim', [0.675, 0.7])
axis equal;
% legend([h1, h2, h3, h4], 'Cell2cell-faceplane intersection', 'face centroid', 'cell centroid', 'voronoi sites');
legend([h2, h3], 'face centroid', 'cell centroid');
%% Finalize
% 130x62: FCF: 0.53, cF: 0.6
% 220x110: FCF: 0.94, cF: 0.6
% 460x64: FCF: 0.56, cF: 0.6
% 898x120: FCF: 1.0, cF: 0.6, useMrstPebi false
nx = 130;
ny = 62;
[G, G2Ds, G2D, Pts] = GeneratePEBIGrid(nx, ny, 'FCFactor', 0.53, 'circleFactor', 0.6, 'save', true, ...
    'bufferVolumeSlice', true, ...
    'useMrstPebi', false, ...
    'earlyReturn', false);
%% Comparison w/o edgeremoval

grids = {G2D, G2Ds};
names = {'stock', 'RSE'};

T = tiledlayout(3, numel(grids));

for ig = 1:numel(grids)
    G = grids{ig};
    N = getNeighbourship(G);
    Conn = getConnectivityMatrix(N);
    [I, J] = find(Conn);
    sz = J(end);
    [~, nbs] = rlencode(J);

    name = names{ig};
    nexttile(0 + ig);
    histogram(nbs);
    title(sprintf('Grid: %s, Cells: %d', name, G.cells.num));
    xlabel('Number of neighbors');
    ylabel('Frequency');
end

for ig = 1:numel(grids)
    G = grids{ig};
    N = getNeighbourship(G);
    Conn = getConnectivityMatrix(N);
    [I, J] = find(Conn);
    sz = J(end);
    [~, nbs] = rlencode(J);

    name = names{ig};
    nexttile(2+ ig);
    histogram(nbs);
    title(sprintf('Grid: %s, Cells: %d', name, G.cells.num));
    xlabel('Number of neighbors');
    ylabel('Frequency');
end

for ig = 1:numel(grids)
    G = grids{ig};
    name = names{ig};
    nexttile(4+ig);
    histogram(log10(G.faces.areas));
    title(sprintf('Grid: %s, Cells: %d', name, G.cells.num));
    xlabel('Log10(face areas)');
    ylabel('Frequency');
end
%%
Gf = G2Ds;
[~, smallestFacesOrder] = sort(Gf.faces.areas);
num = 10;
smallestFaceNbs = Gf.faces.neighbors(smallestFacesOrder(1:num),:);
smallestFaceNbs = unique(reshape(smallestFaceNbs, [], 1));
% plotGrid(Gf, 'facecolor', 'none');
plotGrid(Gf, smallestFaceNbs)
%%
plotGrid(G, 'facecolor', 'none');axis tight equal;
plotGrid(G, G.cells.wellCells);view(0,0);
% plotCellData(G2Ds, G2Ds.cells.tag);axis tight equal;
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