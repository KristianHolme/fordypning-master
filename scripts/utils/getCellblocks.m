function cellblocks = getCellblocks(simcase, varargin)
    opt = struct('paddingLayers', 1);
    opt = merge_options(opt, varargin{:});
    
    paddingLayers = opt.paddingLayers;
    G = simcase.G;
    [cell1, cell2] = simcase.getinjcells;
    injectionsCells = [cell1; cell2];
    tpfaCells = findCellNeighbors(G, injectionsCells, paddingLayers);

    if contains(simcase.discmethod, 'ntpfa','IgnoreCase', true)
        bccells = getbcCells(simcase);
        bccells = findCellNeighbors(G, bccells, paddingLayers);
        tpfaCells = union(tpfaCells, bccells);
    end
    


    otherCells = setdiff((1:G.cells.num)', tpfaCells);

    cellblocks{1} = tpfaCells;
    cellblocks{2} = otherCells;
end


