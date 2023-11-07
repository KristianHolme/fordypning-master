function cellblocks = getCellblocks(simcase, varargin)
    opt = struct('paddingLayers', 1);
    opt = merge_options(opt, varargin{:});
    
    paddingLayers = opt.paddingLayers;
    G = simcase.G;
    pdisc = simcase.pdisc;
    injectionCells = [];
    if ~isempty(simcase.schedule) && ~isempty(simcase.schedule.control(1).W)
        [cell1, cell2] = simcase.schedule.control(1).W.cells;
        injectionCells = [cell1; cell2];
    end
    tpfaCells = findCellNeighbors(G, injectionCells, paddingLayers);


    if ~isempty(pdisc) && contains(pdisc, 'ntpfa','IgnoreCase', true)
        bccells = getbcCells(simcase);
        bccells = findCellNeighbors(G, bccells, paddingLayers);
        tpfaCells = union(tpfaCells, bccells);
    end
    


    otherCells = setdiff((1:G.cells.num)', tpfaCells);

    cellblocks{1} = tpfaCells;
    cellblocks{2} = otherCells;
end


