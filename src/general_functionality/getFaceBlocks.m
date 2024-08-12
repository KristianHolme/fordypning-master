function faceBlocks = getFaceBlocks(G, cellblocks, varargin)
    opt = struct('prio', 1);
    opt = merge_options(opt, varargin{:});

    % prio is the prioritized cell block, should be 1 or 2
    % 1 means all tpfacells will get tpfa faces
    assert(opt.prio == 1 || opt.prio == 2)

    prioCells = cellblocks{opt.prio};
    prioFaces = unique(G.cells.faces(mcolon(G.cells.facePos(prioCells), G.cells.facePos(prioCells+1)-1)));
    faceBlocks{opt.prio} = prioFaces;
    otherFaces = setdiff(1:G.faces.num, prioFaces);
    faceBlocks{3-opt.prio} = otherFaces;
    assert(numel(faceBlocks{1}) + numel(faceBlocks{2}) == G.faces.num)
end