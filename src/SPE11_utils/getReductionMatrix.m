%
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
    repsteps = [round(logspace(0, log10(numFineCells/2), 5)), round(linspace(numFineCells*6/10, numFineCells, 5))];
    
    Gr = cartGrid([nx, ny], [xlimit, zlimit]);
    % Gr = computeGeometry(Gr);
    Gr = makeLayeredGrid(Gr, 1);
    Gr = computeGeometry(Gr);
    Gr = rotateGrid(Gr);
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
    
    iterationLimit = opt.iterationLimit;
    sumTol = opt.tol;
    
    gridPoly = polyshape([0, 0;xlimit, 0;xlimit, zlimit;0, zlimit]);
    
    % Pre-allocate cell arrays for parallel processing
    numEntries = 4*numFineCells;
    spRowsCell = cell(numFineCells, 1);
    spColsCell = cell(numFineCells, 1);
    spValsCell = cell(numFineCells, 1);
    numInCellsArray = zeros(numFineCells, 1);
    easyCasesArray = zeros(numFineCells, 1);
    maxitersArray = zeros(numFineCells, 1);

    % Setup progress tracking
    progress = parallel.pool.DataQueue;
    if opt.verbose
        afterEach(progress, @(i) updateProgressCount(i, numFineCells, repsteps));
        fprintf('Starting parallel processing of %d cells...\n', numFineCells);
    end
    
    % Replace the main for loop with parfor
    parfor ic = 1:numFineCells
        % Local variables for this iteration
        fractionsFine = zeros(totCoarseCells,1);
        fractionInCoarse = zeros(totCoarseCells,1);
        
        faces = gridCellFaces(G, ic);
        normals = G.faces.normals(faces,:);
        flipadjust = (G.faces.neighbors(faces,2) == ic)*2 - 1;
        normals = normals .* flipadjust;
        areas = G.faces.areas(faces);
        face = faces( find( abs( ((normals * outVec)-areas)) < tol, 1) );
    
        nodes = gridFaceNodes(G, face);
        nodeCoords = G.nodes.coords(nodes,:);
        
        coarsecells = unique([nodeEncCells(nodes);cellEncCells(ic)]);
        numCoarse = numel(coarsecells);
    
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
            maxitersArray(ic) = iterations;
            assert(abs(sum(fractionsFine)-fractionTarget)< sumTol, sprintf('Breaking tolerance for cell %d. Iterations = %d', ic, iterations));
        else
            easyCasesArray(ic) = 1;
            fractionInCoarse(coarsecells) = G.cells.volumes(ic)/Gr.cells.volumes(coarsecells);
        end
        
        % Store results in cell arrays instead of directly in sparse matrix
        numInCells = numel(coarsecells);
        spRowsCell{ic} = coarsecells;
        spColsCell{ic} = ic * ones(numInCells, 1);
        spValsCell{ic} = fractionInCoarse(coarsecells);
        numInCellsArray(ic) = numInCells;

        % Update progress
        if opt.verbose
            send(progress, 1);
        end
    end
    tloop = toc(tloop);
    
    % Combine results after parallel execution
    totalEntries = sum(numInCellsArray);
    spRows = zeros(totalEntries, 1);
    spCols = zeros(totalEntries, 1);
    spVals = zeros(totalEntries, 1);
    
    index = 1;
    for ic = 1:numFineCells
        numInCells = numInCellsArray(ic);
        if numInCells > 0
            idx = index:(index+numInCells-1);
            spRows(idx) = spRowsCell{ic};
            spCols(idx) = spColsCell{ic};
            spVals(idx) = spValsCell{ic};
            index = index + numInCells;
        end
    end
    
    M = sparse(spRows, spCols, spVals, totCoarseCells, numFineCells);
    report.easyCases = sum(easyCasesArray);
    report.maxiters = max(maxitersArray);
    
    warning('on', 'MATLAB:polyshape:repairedBySimplify');
    
    report.initTime = tstart;
    report.loopTime = tloop;
    
    dispif(opt.verbose, 'Finished in %0.1f s, %0.1f (init) + %0.1f (cell loop)\n', tstart+tloop, tstart, tloop);
end

function updateProgressCount(i, total_cells, report_steps)
    persistent progress_count
    if isempty(progress_count)
        progress_count = 0;
        % total_cells = evalin('base', 'numFineCells');
        % report_steps = evalin('base', 'repsteps');
    end
    progress_count = progress_count + i;
    
    if ismember(progress_count, report_steps)
        fprintf('%d/%d Computing...\n', progress_count, total_cells);
    end
end