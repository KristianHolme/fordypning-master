function [M, Gr, report] = getReductionMatrix(G, nx, ny, varargin)
%return a matrix where M(i, j) is how much of the volume of cell j in G is
%in cell i in Gr. Volume is fraction of the volume of the cell in Gr.
%nx, ny is cartesian resolution of Gr
opt = struct('SPEcase', 'B', ...
    'verbose', true, ...
    'tol', 1e-4, ...
    'iterationLimit', 100);
opt = merge_options(opt, varargin{:});

dispif(opt.verbose, 'Calculating reductionMatrix...\n');
tstart = tic();

switch opt.SPEcase
    case 'B'
        xlimit = 8400;
        zlimit = 1200;
end
numFineCells = G.cells.num;
repsteps = round(logspace(0, log10(numFineCells), 10));

Gr = cartGrid([nx, ny], [xlimit, zlimit]);
% Gr = computeGeometry(Gr);
Gr = makeLayeredGrid(Gr, 1);
Gr = computeGeometry(Gr);
Gr = RotateGrid(Gr);
Gr = computeGeometry(Gr);
totCoarseCells = Gr.cells.num;

% N = getNeighbourship(Gr);
N = neighboursByNodes(Gr);
A = getConnectivityMatrix(N, false);

% M = sparse(Gr.cells.num, numFineCells);

frontNodeIxs = G.nodes.coords(:,2)<0.05;
frontnodeCoords = G.nodes.coords(frontNodeIxs,:);
frontnodeCoords(:,2) = 0.5;
nodeEncCells = zeros(G.nodes.num,1);

% nodeEncCells(frontNodeIxs) = findEnclosingCell(Gr, frontnodeCoords);
% cellEncCells = findEnclosingCell(Gr, G.cells.centroids);

nodeEncCells(frontNodeIxs) = closestPoints(Gr.cells.centroids(:,[1,3]), frontnodeCoords(:,[1,3]));
cellEncCells = closestPoints(Gr.cells.centroids(:,[1,3]), G.cells.centroids(:,[1,3]));

warning('off', 'MATLAB:polyshape:repairedBySimplify');
outVec = [0;1;0];
tol = 1e-6;
tstart = toc(tstart);
tloop = tic();

numEntries = 4*numFineCells;
spRows = zeros(numEntries,1);
spCols = zeros(numEntries,1);
spVals = zeros(numEntries,1);

index = 1;
easyCases = 0;
maxiters = 0;
iterationLimit = opt.iterationLimit;
sumTol = opt.tol;

gridPoly = polyshape([0, 0;xlimit, 0;xlimit, zlimit;0, zlimit]);

for ic = 1:numFineCells
    faces = gridCellFaces(G, ic);
    normals = G.faces.normals(faces,:);
    flipadjust = (G.faces.neighbors(faces,2) == ic)*2 - 1;
    normals = normals .* flipadjust;
    areas = G.faces.areas(faces);
    face = faces( find( abs( ((normals * outVec)-areas)) < tol, 1) );

    nodes = gridFaceNodes(G, face);
    nodeCoords = G.nodes.coords(nodes,:);
    % cellcentroid = G.cells.centroids(ic,:);
    % % faceCoords = G.faces.centroids(faces,:);
    % % allCoords = [nodeCoords;faceCoords;cellcentroid];
    % allCoords = [nodeCoords;cellcentroid];
    % allCoords(:,2) = 0.5;
    
    coarsecells = unique([nodeEncCells(nodes);cellEncCells(ic)]);
    % coarsecells = cellEncCells(ic);
    % coarsecells = unique(findEnclosingCell(Gr, allCoords));
    numCoarse = numel(coarsecells);
    fractionsFine = zeros(totCoarseCells,1);
    fractionInCoarse = zeros(totCoarseCells,1);

    if numCoarse > 1
       

        cellPoly = polyshape(nodeCoords(:,1), nodeCoords(:,3));
        origarea = area(cellPoly);
        coveredCells = 0;
        iterations = 0;

        inGrid = intersect(cellPoly, gridPoly);
        areaInGrid = area(inGrid);
        fractionTarget = areaInGrid/origarea;

        while abs(sum(fractionsFine)-fractionTarget) > sumTol && iterations < iterationLimit
            iterations = iterations + 1;

            [~, J] = find(A(coarsecells,:));
            neighbors = setdiff(unique(J), coarsecells);
            coarsecells = unique([coarsecells; neighbors], 'stable');
            numCoarse = numel(coarsecells);

            
            for icc = (coveredCells+1):numCoarse
                coarseCell = coarsecells(icc);
                coarseFaces = gridCellFaces(Gr,coarseCell);
                coarseFace = coarseFaces(1);%change face
                coarseNodes = gridFaceNodes(Gr, coarseFace);
                % coarseNodes = coarseNodes(Gr.nodes.coords(coarseNodes,2)<0.05);
                coarsePoly = polyshape(Gr.nodes.coords(coarseNodes,1), Gr.nodes.coords(coarseNodes,3));
                coarseArea = area(coarsePoly);
                intsct = intersect(coarsePoly, cellPoly);
                fractionsFine(coarseCell) = area(intsct)/origarea;
                fractionInCoarse(coarseCell) = area(intsct)/coarseArea; %we want to record fraction of the coarse cell
            end
            coveredCells = coveredCells + numel(neighbors);
        end
        maxiters = max(maxiters, iterations);
        % clf;
        % plotGrid(G, ic, 'facecolor', 'yellow', 'facealpha', 0.2);view(0,0);hold on;
        % plotGrid(Gr, coarsecells, 'facecolor', 'blue', 'facealpha', 0.2);hold off;
        assert(abs(sum(fractionsFine)-fractionTarget)< sumTol, sprintf('Breaking tolerance for cell %d. Iterations = %d', ic, iterations));
    else
        easyCases = easyCases +1;
        fractionInCoarse(coarsecells) = G.cells.volumes(ic)/Gr.cells.volumes(coarsecells);
    end
    numInCells = numel(coarsecells);
    spRows(index:index+numInCells-1) = coarsecells;
    spCols(index:index+numInCells-1) = ic;
    spVals(index:index+numInCells-1) = fractionInCoarse(coarsecells);
    index = index + numInCells;


    dispif(opt.verbose && ismember(ic, repsteps), '%d/%d Computing...\n', ic, numFineCells);
end
tloop = toc(tloop);
warning('on', 'MATLAB:polyshape:repairedBySimplify');

spRows = spRows(1:index-1);
spCols = spCols(1:index-1);
spVals = spVals(1:index-1);
M = sparse(spRows, spCols, spVals, totCoarseCells, numFineCells);

report.easyCases = easyCases;
report.initTime = tstart;
report.loopTime = tloop;
report.maxiters = maxiters;

dispif(opt.verbose, 'Finished in %0.1f s, %0.1f (init) + %0.1f (cell loop)\n', tstart+tloop, tstart, tloop);
end