function G = addBoxWeights(G, varargin)
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
        volumeFractions = getVolumeFractions(G, p1, p2, vertIx);
        G.cells.(['fractionIn', box]) = volumeFractions;
    end
end

function volumeFractions = getVolumeFractions(G, p1, p2, vertIx)
    pts = [p1(1), p2(2);
            p2(1), p2(2);
            p2(1), p1(2);
            p1(1), p1(2);
            p1(1), p2(2)];
    
    boxpoly = polyshape(pts);
    
    ccin = getSubCellsInBox(G, pts(4,:), pts(2,:));
    
    if ~isfield(G.cells,'neighbors')
            nbs = getNeighbourship(G);
            Conn = getConnectivityMatrix(nbs);
            G.cells.neighbors = getnbsByConn(Conn);
    end
    depthIx = 5-vertIx;
    
    cn = cellNodes(G);
    allcandidates = unique(vertcat(G.cells.neighbors{ccin}));
    numCand = numel(allcandidates);
    candidatenodes = cell(numCand, 1);
    volumeFractions = zeros(G.cells.num,1);
    for icand = 1:numCand
        globcelIx = allcandidates(icand);
        candNodes = cn(cn(:,1)==globcelIx,3);
        candidatenodes{icand} = candNodes;
        %Only want nodes in y=0
        candNodeCoords = G.nodes.coords(candNodes,:);
        candNodeCoords = candNodeCoords(:,depthIx) == 0.0;
        candNodesXIn = candNodeCoords(:,1) > p1(1) & candNodeCoords(:,1) < p2(1);
        candNodesVIn = candNodeCoords(:,vertIx) > p1(vertIx) & candNodeCoords(:,vertIx) < p2(vertIx);
        candNodesIn = candNodesXIn & candNodesVIn;
    
        if all(candNodesIn)
            volumeFractions(allcandidates(icand)) = 1;
        elseif ~any(candNodesIn)
            volumeFractions(allcandidates(icand)) = 0;
        else
            coordslooped = [candNodeCoords;candNodeCoords(1,:)];
            candshape = polyshape(coordslooped);
            origarea = polyarea(candshape);
            polyInBox = intersect(candshape, boxpoly);
            areaInBox = polyarea(polyInBox);
            fraction = areaInBox/origarea;
            volumeFractions(allcandidates(icand)) = fraction;
        end
    end
end