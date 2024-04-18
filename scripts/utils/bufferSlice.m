function  G = bufferSlice(G, SPEcase)
    
    assert(~strcmp(SPEcase, 'A'));
    dispif(true, "Slicing to add buffervolume...\n");
    [G, gix] = sliceGrid(G, {[1, 0.5, 0], [8399, 0.5, 0]}, 'normal', [1 0 0]);
    dispif(true, "Done slicing.\n");
    G.cells.tag = G.cells.tag(gix.parent.cells);
    % rock = simcase.rock;
    % rock.perm = rock.perm(gix.parent.cells,:);
    % rock.poro = rock.poro(gix.parent.cells);
    % rock.regions.saturation = G.cells.tag;%not sure, do it to be safe??
    % simcase.rock = rock;
end