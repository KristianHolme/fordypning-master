function rock = setupRock(simcase, varargin)
    opt = struct('deck', false);
    opt = merge_options(opt, varargin{:});

    if simcase.jutulThermal
        gridRockfile = fullfile("~/Code/CSP11_JutulDarcy.jl/data/", [simcase.gridcase, '.mat']);
        load(gridRockfile)
        return
    end

    if opt.deck
        rock = initEclipseRock(simcase.deck);
        active = G.cells.indexMap;
        rock = compressRock(rock, active);
    end
    
    % G = setupGrid(simcase, 'extra', false); %no circular dependency
    G = simcase.G;
    gridcase = simcase.gridcase;
    if ~isempty(gridcase) && contains(gridcase, 'skewed3D')
        rock = makeRock(G, 100*milli*darcy, .2);
        return
    end
    if contains(simcase.tagcase, 'normalRock')
        rock = initEclipseRock(simcase.deck);
        active = G.cells.indexMap;
        rock = compressRock(rock, active);
        G.cells.tag = rock.regions.saturation;
        % geodata = readGeo('./scripts/geo-files/spe11a.geo', 'assignExtra', true);
        % geodata = stretchGeo(rotateGrid(geodata));
        % G = tagbyFacies(G, geodata, 'vertIx', 3); %tagging grid in xz plane
    end
    if isfield(G.cells, 'tag') && ~contains(simcase.tagcase, 'deckrock')
        if strcmp(simcase.SPEcase, 'A')
            faciesPerm      = [4e-11; 5e-10;1e-9; 2.0e-9; 4e-9; 1e-8; 0.0];
            faciesPoro      = [0.44; 0.43; 0.44; 0.45; 0.43; 0.46; 0.0];
            rock.perm       = faciesPerm(G.cells.tag);
            rock.poro   = faciesPoro(G.cells.tag);
            rock.regions.saturation = G.cells.tag;
        else
            faciesPerm      = [1e-16; 1e-13; 2e-13; 5e-13; 1e-12; 2e-12; 0.0];
            faciesPoro      = [0.1; 0.2; 0.2; 0.2; 0.25; 0.35; 0.0];
            rock.perm       = faciesPerm(G.cells.tag);
            if G.griddim == 3
                rock.perm(:, end+1) = faciesPerm(G.cells.tag);%same perm in y direction
            end
            rock.perm(:, end+1) = faciesPerm(G.cells.tag)*0.1;
            rock.poro   = faciesPoro(G.cells.tag);
            rock.regions.saturation = G.cells.tag;

            if strcmp(simcase.SPEcase, 'C') && ~contains(simcase.tagcase, 'diagperm') && (~simcase.nonStdGrid || contains(simcase.gridcase, 'tet'))
                fullperm = zeros(G.cells.num, 6);
                fullperm(:,[1,4,6]) = rock.perm;
                v = G.cells.centroids(:,2);
                scaling = -(0.12)*(v/2500-1)+0.002;
                xperm = fullperm(:,1);%perm in x dir
                fullperm(:,5) = -xperm .* scaling;
                fullperm(:,6) = fullperm(:,6) + xperm .* (scaling.^2);
                rock.perm = fullperm;                
            end
            

            if isfield(G, 'buffereps')
                eps = G.buffereps;
            else
                eps = 1;
            end
            [~, rock] = addBufferVolume(G, rock, ...
                'eps', eps,...
                'bufferMult', contains(simcase.tagcase, 'bufferMult'), ...
                'hasCorrectBufferVolumes', simcase.nonStdGrid);

        end
    elseif simcase.usedeck
        rock = initEclipseRock(simcase.deck);
        active = simcase.deck.GRID.ACTNUM;
        rock = compressRock(rock, active);
    end
end