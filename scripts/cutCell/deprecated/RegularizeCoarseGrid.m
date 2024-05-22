function G = RegularizeCoarseGrid(CG)
    G = CG;
    nodePos = zeros(CG.faces.num +1, 1);
    nodePos(1) = 1;
    nodes = []; 
    for iface = 1:CG.faces.num
        faces = CG.faces.fconn(CG.faces.connPos(iface) : CG.faces.connPos(iface + 1) - 1);
        newNodes = arrayfun(@(f)CG.parent.faces.nodes(CG.parent.faces.nodePos(f):CG.parent.faces.nodePos(f+1)-1), faces, UniformOutput=false);
        newNodes = unique(cell2mat(newNodes));
        nodePos(iface +1) = nodePos(iface) + numel(newNodes) + 1;
        nodes = [nodes, newNodes];

    end 
    CG.nodes = CG.parent.nodes;
    CG.faces.nodePos = nodePos;
    CG.faces.nodes = nodes;
    %PROBLEM? now faces contains nodes that are unnecessary, dont know if
    %this affect computeGeometry??
end
