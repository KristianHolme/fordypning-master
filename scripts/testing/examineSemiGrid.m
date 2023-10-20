clear all
close all
%%
load("11thSPE-CSP\geometries\11AFiles\spe11a_semi200x150_0.5_grid.mat")

%%
load("Misc\goodparams.mat");
goodparams(:, 4) = goodparams(:,1) .* goodparams(:,2);%resolution
% Find index of highest value in the fourth column
[~, idx_maxRes] = max(goodparams(:, 4));
[~, idx_max_x] = max(goodparams(:, 1));
[~, idx_max_z] = max(goodparams(:, 2));

% Find index of lowest value in the fourth column
[~, idx_minRes] = min(goodparams(:, 4));
[~, idx_min_x] = min(goodparams(:, 1));
[~, idx_min_z] = min(goodparams(:, 2));

% Extract corresponding rows from first three columns
maxResolParams = goodparams(idx_maxRes, 1:3);
minResolParams = goodparams(idx_minRes, 1:3);
max_xParams = goodparams(idx_max_x, 1:3);
min_xParams = goodparams(idx_min_x, 1:3);
max_zParams = goodparams(idx_max_z, 1:3);
min_zParams = goodparams(idx_min_z, 1:3);
%%
n = randi(size(goodparams,1));

%%
n = 2;
params = goodparams(n,:);
params = maxResolParams;
params = [200 150 0.5];
savegrid = true;
nx = params(1);nz = params(2); density = params(3);

G = genHybridGrid('nx', nx, 'nz', nz, 'density', density, 'savegrid', savegrid);

%%
zeroAreaFaces = find(G.faces.areas <=0);
%%
plotGrid(G, 'facealpha', 0, 'edgealpha', 0.2);axis tight;hold on;
for i =1:numel(zeroAreaFaces)
    face = zeroAreaFaces(i);
    nodes = G.faces.nodes(G.faces.nodePos(face):G.faces.nodePos(face+1)-1);
    nodecoords = G.nodes.coords(nodes,:);
    plot(nodecoords(:,1), nodecoords(:,2), 'color', 'r','LineWidth', 2);
end
hold off;
%% Test line 2
load("11thSPE-CSP\geometries\11AFiles\spe11a_semi200x150_0.5_grid.mat")
G = uniqueifyNodes(G);
G = removeCollapsedFaces(G);
G = computeGeometry(G);
G = makeLayeredGrid(G, 0.01);
G = computeGeometry(G);
G = removePinch(G);
G = computeGeometry(G);
ok = checkGrid(G);

%% Test line 1
G = makeLayeredGrid(G, 0.01);
G = removePinch(G);
G = computeGeometry(G);
ok = checkGrid(G);

%%
plotGrid(G, 'facealpha', 0, 'edgealpha', 0.1);
%%
checkGrid(G)
%%
min(G.faces.areas)
%%
NanFaces = find(isnan(cc));
%% Debugging in checkGrid
wrong_normals_idx = find(sum(ncc .* cc, 2) <= 0);

wrong_normals_global_idx = G.cells.faces(wrong_normals_idx, 1);
wrong_normals_cells = cellno(wrong_normals_idx);

nanCentroidCells = find(isnan(G.cells.centroids(:,1)) | isnan(G.cells.centroids(:,2)));
plotGrid(G, 'facealpha', 0, 'edgealpha', 0.1);
plotGrid(G, nanCentroidCells);
%%
ic = 2;
nanCentroidFaces = G.cells.faces(G.cells.facePos(nanCentroidCells(ic)):G.cells.facePos(nanCentroidCells(ic)+1)-1);
nanCentroidFacesNeighbors = G.faces.neighbors(nanCentroidFaces, :);
%%
plotFaces(G, nanCentroidFaces, 'facecolor', 'red', 'linewidth', 2);

%%
plotGrid(G, 'facealpha', 0, 'edgealpha', 0.1);plotFaces(G, wrong_normals_global_idx, 'linewidth', 2)
% plotGrid(G, wrong_normals_cells(1))
%%
c1 = [0.328484, 0.150529];
c2 = [0.318002, 0.143706];
[~, ix1] = min(vecnorm(G.nodes.coords - c1, 2, 2));
[~, ix2] = min(vecnorm(G.nodes.coords - c2, 2, 2));
%%
G.nodes.coords([ix1, ix2], :) = G.nodes.coords([ix2, ix1], :);
%%
Gs = extractSubgrid(G, 19033);
%%
plotGrid(G)

%%
N = findMatchingFaces(G);

%%
G = repairNormals(G);
%%
pointEdges = find(G.faces.areas < 1e-18);
G = removeFaces(G, pointEdges);

%%
nancells = cellno(isnan(G.cells.centroids(cellno,:)));

%%
tol = 1e-12;

function G = uniqueifyNodes(G, varargin)
    opt = struct('tol', 1e-12);
    opt = merge_options(opt, varargin{:});
    tol = opt.tol;

    % Uniquify nodes
    [G.nodes.coords, i, j] = unique(G.nodes.coords, 'rows');
    
    % Map face nodes
    G.faces.nodes    = j(G.faces.nodes);
    
    % Remove nodes with small difference
    if tol>0
      d = [inf; sqrt(sum(diff(G.nodes.coords,1) .^ 2, 2))];
      I = d < tol;
      G.nodes.coords = G.nodes.coords(~I,:);
      J = ones(size(I));
      J(I) = 0;  J = cumsum(J);
      G.faces.nodes = J(G.faces.nodes);
    end
    G.nodes.num = size(G.nodes.coords, 1);
end

function G = removeCollapsedFaces(G)
    % Identify faces with the same start and end node
    nodeStart = G.faces.nodes(G.faces.nodePos(1:end-1));
    nodeEnd = G.faces.nodes(G.faces.nodePos(2:end) - 1);
    selfLoopingLog = nodeStart == nodeEnd;
    cs_selfLoopingLog = cumsum(selfLoopingLog);
    oldToNewFaces = (1:G.faces.num)' - cs_selfLoopingLog;
    newToOldFaces = find(~selfLoopingLog);
    selfLooping = find(selfLoopingLog);

    newNumFaces = G.faces.num - numel(selfLooping);
    G.faces.num = newNumFaces;
    G.faces.nodes([G.faces.nodePos(selfLooping); G.faces.nodePos(selfLooping+1)-1]) = [];
    cs_facesToBeDeleted = cumsum(diff(G.faces.nodePos).*selfLoopingLog);
    G.faces.nodePos(1:end-1) = G.faces.nodePos(1:end-1) - cs_facesToBeDeleted;
    G.faces.nodePos(end) = G.faces.nodePos(end) - cs_facesToBeDeleted(end);
    G.faces.nodePos(selfLooping) = [];
    G.faces.areas = G.faces.areas(newToOldFaces);
    G.faces.neighbors = G.faces.neighbors(newToOldFaces, :);
    G.faces.centroids = G.faces.centroids(newToOldFaces);
    G.faces.normals = G.faces.normals(newToOldFaces, :);
    G.faces.global = G.faces.global(newToOldFaces); %not sure what this is, but change it anyways


    % Initialize new facePos
    newFacePos = zeros(G.cells.num + 1, 1);
    newFacePos(1) = 1;
    
    % Update face numbering in cells
    newFaces = [];
    for i = 1:G.cells.num
        faceIDs = G.cells.faces(G.cells.facePos(i):G.cells.facePos(i+1)-1);
        newFaceIDs = setdiff(faceIDs, selfLooping);
        
        newFaces = [newFaces; oldToNewFaces(newFaceIDs)];
        newFacePos(i + 1) = newFacePos(i) + numel(newFaceIDs);
    end
    G.cells.faces = newFaces;
    G.cells.facePos = newFacePos;
end
