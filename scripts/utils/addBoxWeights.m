function G = addBoxWeights(G, varargin)
%NOT TESTED for SPE11A!! wont work
    opt = struct('SPEcase', 'B');
    opt = merge_options(opt, varargin{:});
    
    boxes = ['A', 'B', 'C'];
    if max(G.nodes.coords(:,3)) > 1.1
        vertIx = 3;
    else
        vertIx =2;
    end
    for ib = 1:numel(boxes)
        box = boxes(ib);
        [p1, p2] = getCSPBoxPoints(G,box, opt.SPEcase);
        volumeFractions = getVolumeFractions(G, p1, p2, vertIx, opt);
        G.cells.(['fractionIn', box]) = volumeFractions;
    end
end

function volumeFractions = getVolumeFractions(G, p1, p2, vertIx, opt)
    pts = [p1(1), p2(2);
            p2(1), p2(2);
            p2(1), p1(2);
            p1(1), p1(2);
            p1(1), p2(2)];
    
    
    
    ccin = getSubCellsInBox(G, pts(4,:), pts(2,:));

    ccin(G.bufferCells) = false;
    
    if ~isfield(G.cells,'neighbors')
            nbs = getNeighbourship(G);
            Conn = getConnectivityMatrix(nbs);
            G.cells.neighbors = getnbsByConn(Conn);
    end
    depthIx = 5-vertIx;
    
    
    allcandidates = unique(vertcat(G.cells.neighbors{ccin}));
    allcandidates = unique(vertcat(G.cells.neighbors{allcandidates}));

    allcandidates = setdiff(allcandidates, G.bufferCells); %don't include buffercells


    [n , pos] = gridCellNodes(G, allcandidates);
    numCand = numel(allcandidates);
    
    if ~strcmp(opt.SPEcase, 'C')
        boxpoly = polyshape(pts);
        volumeFractions = polyVolumeFractions(G, n, pos, numCand, allcandidates, depthIx, vertIx, p1, p2, boxpoly);
    else
        volumeFractions = approxVolumeFractions(G, n, pos, numCand, allcandidates, vertIx, p1, p2);  
    end
    %----
    % clf;
    % plot3(pts(:,1), zeros(size(pts,1),1), pts(:,2));hold on;view(0,0);
    %----

    
end

function volumeFractions = polyVolumeFractions(G, n, pos, numCand, allcandidates, depthIx, vertIx, p1, p2, boxshape)
volumeFractions = zeros(G.cells.num,1);
warning('off', 'MATLAB:polyshape:repairedBySimplify');
for icand = 1:numCand
    % globcelIx = allcandidates(icand);
    candNodes = n(pos(icand):pos(icand+1)-1);
    %Only want nodes in y=0
    nodeCoords = G.nodes.coords(candNodes,:);
    nodeCoords = nodeCoords(nodeCoords(:,depthIx) == 0.0,:);
    candNodesXIn = nodeCoords(:,1) > p1(1) & nodeCoords(:,1) < p2(1);
    candNodesVIn = nodeCoords(:,vertIx) > p1(2) & nodeCoords(:,vertIx) < p2(2);
    candNodesIn = candNodesXIn & candNodesVIn;
    %-----------
    % plotGrid(G, allcandidates(icand), 'facealpha', 0.5, 'edgealpha', 0.5)
    %----------
    if all(candNodesIn)
        volumeFractions(allcandidates(icand)) = 1;
    elseif ~any(candNodesIn)
        volumeFractions(allcandidates(icand)) = 0;
    else
        % coordslooped = [candNodeCoords;candNodeCoords(1,:)];
        cellShape = polyshape(nodeCoords(:,1), nodeCoords(:,vertIx));
        origarea = area(cellShape);
        polyInBox = intersect(cellShape, boxshape);
        areaInBox = area(polyInBox);
        fraction = areaInBox/origarea;
        volumeFractions(allcandidates(icand)) = fraction;
    end
end
warning('on', 'MATLAB:polyshape:repairedBySimplify');
end

function volumeFractions = approxVolumeFractions(G, n, pos, numCand, allcandidates, vertIx, p1, p2)
testing = false;
volumeFractions = zeros(G.cells.num, 1);
numSampsTarget = 10000;
% boxVolTot = (p2(1)-p1(1))*(p2(2)-p1(2))*4998;

for icand = 1:numCand
    % globcelIx = allcandidates(icand);
    candNodes = n(pos(icand):pos(icand+1)-1);
    numCandNodes = numel(candNodes);
    cellNodeCoords = G.nodes.coords(candNodes,:);
    candNodesXIn = cellNodeCoords(:,1) > p1(1) & cellNodeCoords(:,1) < p2(1);
    candNodesVIn = cellNodeCoords(:,vertIx) >= p1(2) & cellNodeCoords(:,vertIx) <= p2(2);
    candNodesIn = candNodesXIn & candNodesVIn;
    if all(candNodesIn)
        volumeFractions(allcandidates(icand)) = 1;
    elseif ~any(candNodesIn)
        volumeFractions(allcandidates(icand)) = 0;
    else
        xmin = min(cellNodeCoords(:,1));
        ymin = min(cellNodeCoords(:,2));
        zmin = min(cellNodeCoords(:,3));
        xmax = max(cellNodeCoords(:,1));
        ymax = max(cellNodeCoords(:,2));
        zmax = max(cellNodeCoords(:,3));

        boundingBoxVol = (xmax-xmin)*(ymax-ymin)*(zmax-zmin);
        d = (boundingBoxVol/numSampsTarget)^(1/3);

        % numSampsX = (p2(1)-p1(1))/d;
        % numSampsY = (p2(2)-p1(2))/d;
        % numSampsZ = 4998/d;
        x = xmin:d:xmax;
        y = ymin:d:ymax;
        z = zmin:d:zmax;
        [X, Y, Z] = meshgrid(x, y, z);
        allCoords = [X(:), Y(:), Z(:)];

        %Make cell shape and find points inside cell
        cellshape = alphaShape(cellNodeCoords, Inf);
        pointsInCell= inShape(cellshape, allCoords(:,1), allCoords(:,2), allCoords(:,3));
        numPointsInCell = sum(pointsInCell);
        pointCoords = allCoords(pointsInCell,:);
        %How many of these points are inside the bpx?
        pointsInsideDirX = pointCoords(:,1) >= p1(1) & pointCoords(:,1) <= p2(1);
        pointsInsideDirZ = pointCoords(:,3) >= p1(2) & pointCoords(:,3) <= p2(2);
        pointsInsideDirY = pointCoords(:,2) >= 1 & pointCoords(:,2) <= 4999;
        pointsInCellAndBox = pointsInsideDirX & pointsInsideDirY & pointsInsideDirZ;
        numPointsInCellAndBox = sum(pointsInCellAndBox);
        fraction = numPointsInCellAndBox/numPointsInCell;
        volumeFractions(allcandidates(icand)) = fraction;

        % weights = rand(numCandNodes, numSamps);
        % % sums = sum(weights, 1);
        % % weights = weights./sums;
        % weights = softmax(weights, 0.12);
        % sampCoords = (candNodeCoords' * weights)';
        % sampCoordsXIn = sampCoords(:,1) > p1(1) & sampCoords(:,1) < p2(1);
        % sampCoordsVIn = sampCoords(:,vertIx) > p1(2) & sampCoords(:,vertIx) < p2(2);
        % sampCoordsIn = sampCoordsXIn & sampCoordsVIn;
        % frac = mean(sampCoordsIn);
        % volumeFractions(allcandidates(icand)) = frac;
        
        % if testing
        %     clf;plotGrid(G, allcandidates(icand), 'facealpha', 0.2);view(60,10);hold on;
        %     % plot3(allCoords(~sampsInCand,1), allCoords(~ sampsInCand,2), allCoords(~sampsInCand,3), 'ro');
        %     plot3(sampCoords(:,1), sampCoords(:,2), sampCoords(:,3), 'bo');            
        % end

    end
end
end
