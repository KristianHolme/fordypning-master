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
    
    
    allcandidates = unique(vertcat(G.cells.neighbors{ccin}));
    allcandidates = unique(vertcat(G.cells.neighbors{allcandidates}));

    [n , pos] = gridCellNodes(G, allcandidates);
    numCand = numel(allcandidates);
    candidatenodes = cell(numCand, 1);
    volumeFractions = zeros(G.cells.num,1);
    %----
    % clf;
    % plot3(pts(:,1), zeros(size(pts,1),1), pts(:,2));hold on;view(0,0);
    %----
    warning('off', 'MATLAB:polyshape:repairedBySimplify');
    for icand = 1:numCand
        globcelIx = allcandidates(icand);
        candNodes = n(pos(icand):pos(icand+1)-1);
        candidatenodes{icand} = candNodes;
        %Only want nodes in y=0
        candNodeCoords = G.nodes.coords(candNodes,:);
        candNodeCoords = candNodeCoords(candNodeCoords(:,depthIx) == 0.0,:);
        candNodesXIn = candNodeCoords(:,1) > p1(1) & candNodeCoords(:,1) < p2(1);
        candNodesVIn = candNodeCoords(:,vertIx) > p1(2) & candNodeCoords(:,vertIx) < p2(2);
        candNodesIn = candNodesXIn & candNodesVIn;
        %-----------
        % plotGrid(G, allcandidates(icand), 'facealpha', 0.5, 'edgealpha', 0.5)
        %----------
        if all(candNodesIn)
            volumeFractions(allcandidates(icand)) = 1;
        elseif ~any(candNodesIn)
            volumeFractions(allcandidates(icand)) = 0;
        else
            coordslooped = [candNodeCoords;candNodeCoords(1,:)];
            candshape = polyshape(candNodeCoords(:,1), candNodeCoords(:,vertIx));
            origarea = area(candshape);
            polyInBox = intersect(candshape, boxpoly);
            areaInBox = area(polyInBox);
            fraction = areaInBox/origarea;
            volumeFractions(allcandidates(icand)) = fraction;
        end
    end
    warning('on', 'MATLAB:polyshape:repairedBySimplify');
end