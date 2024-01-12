function G = RegularizeCoarseGrid(CG)

    
    G = struct();
    blockToCell = find(CG.cells.volumes);
    cellToBlock = @(c) find(blockToCell == c);
    G.cells.num = numel(blockToCell);
    G.cells.facePos = ones(G.cells.num+1);
    G.cells.faces = zeros(sum(diff(CG.cells.facePos)));
    G.cells.facePos = unique(CG.cells.facePos);
    G.cells.faces = CG.cells.faces;
    G.faces = CG.faces;
    nonzero1 = G.faces.neighbors(:,1) ~= 0;
    nonzero2 = G.faces.neighbors(:,2) ~= 0;
    G.faces.neighbors(nonzero1,1) =  arrayfun(cellToBlock, G.faces.neighbors(nonzero1,1));
    G.faces.neighbors(nonzero2,2) = arrayfun(cellToBlock, G.faces.neighbors(nonzero2,2));
    G.nodes = CG.parent.nodes;
    G.griddim = CG.griddim;
    G.type = CG.type;
    G.faces.nodePos = ones(G.faces.num+1,1);
    
    nodesPeroldFace = diff(CG.parent.faces.nodePos);

    for iface = 1:G.faces.num
        oldfaces = G.faces.fconn(G.faces.connPos(iface) : G.faces.connPos(iface + 1) - 1);
        G.faces.nodePos(iface+1) = G.faces.nodePos(iface)+sum(nodesPeroldFace(oldfaces));
    end
    G.faces.nodes = zeros(G.faces.nodePos(end)-1,1);
    for iface = 1:G.faces.num
        oldfaces = G.faces.fconn(G.faces.connPos(iface) : G.faces.connPos(iface + 1) - 1);
        oldFaceToNodes = @(f) CG.parent.faces.nodes(CG.parent.faces.nodePos(f):CG.parent.faces.nodePos(f+1)-1);
        nodes = arrayfun(oldFaceToNodes, oldfaces, 'UniformOutput',false);
        nodes;
        G.faces.nodes(G.faces.nodePos(iface):G.faces.nodePos(iface+1)-1); 
    end
end