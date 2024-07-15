function  G = bufferSlice(G, SPEcase, varargin)
    
    assert(~strcmp(SPEcase, 'A'));
    dispif(true, "Slicing to add buffervolume...\n");
    [G, gix] = sliceGrid(G, {[1, 0.5, 0], [8399, 0.5, 0]}, 'normal', [1 0 0]);
    dispif(true, "Done slicing.\n");
    G.cells.tag = G.cells.tag(gix.parent.cells);

end