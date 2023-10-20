function rock = setupRock11A(simcase)
    G = simcase.G;
    gridcase = simcase.gridcase;
    if ~isempty(gridcase) && contains(gridcase, 'skewed3D')
        rock = makeRock(G, 100*milli*darcy, .2);
        return
    end
    if isfield(G.cells, 'tag')
        faciesPerm      = [4e-11; 5e-10;1e-9; 2.0e-9; 4e-9; 1e-8; 0.0];
        faciesPoro      = [0.44; 0.43; 0.44; 0.45; 0.43; 0.46; 0.0];
        
        
        rock.perm   = faciesPerm(G.cells.tag);
        rock.poro   = faciesPoro(G.cells.tag);
        rock.regions.saturation = G.cells.tag;
    elseif simcase.usedeck
        rock = initEclipseRock(simcase.deck);
        active = G.cells.indexMap;
        rock = compressRock(rock, active);
    end
end