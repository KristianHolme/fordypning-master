function rock = setupRock(simcase)
    G = simcase.G;
    gridcase = simcase.gridcase;
    if ~isempty(gridcase) && contains(gridcase, 'skewed3D')
        rock = makeRock(G, 100*milli*darcy, .2);
        return
    end
    if isfield(G.cells, 'tag')
        if strcmp(simcase.SPEcase, 'A')
            faciesPerm      = [4e-11; 5e-10;1e-9; 2.0e-9; 4e-9; 1e-8; 0.0];
            faciesPoro      = [0.44; 0.43; 0.44; 0.45; 0.43; 0.46; 0.0];
            rock.perm       = faciesPerm(G.cells.tag);
        elseif strcmp(simcase.SPEcase, 'B')
            faciesPerm      = [1e-16; 1e-13; 2e-13; 5e-13; 1e-12; 2e-12; 0.0];
            faciesPoro      = [0.1; 0.2; 0.2; 0.2; 0.25; 0.35; 0.0];
            rock.perm       = faciesPerm(G.cells.tag);
            if G.griddim == 3
                rock.perm(:, end+1) = faciesPerm(G.cells.tag)*0;
            end
            rock.perm(:, end+1) = faciesPerm(G.cells.tag)*0.1;
        end
        
        rock.poro   = faciesPoro(G.cells.tag);
        rock.regions.saturation = G.cells.tag;
    elseif simcase.usedeck
        rock = initEclipseRock(simcase.deck);
        active = G.cells.indexMap;
        rock = compressRock(rock, active);
    end
end