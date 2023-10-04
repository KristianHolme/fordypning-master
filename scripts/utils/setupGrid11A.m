function G = setupGrid11A(simcase, varargin)
    opt = struct('refinement_factor', 1, 'dim', 3);
    opt = merge_options(opt, varargin{:});

    gridcase = simcase.gridcase;

    if ~isempty(gridcase) && contains(gridcase, 'tetRef')
        refinement_factor = str2double(replace(gridcase, 'tetRef', ''));
        if strcmp(simcase.user, 'holme')
            geometriesFolder = "C:\Users\holme\OneDrive\Dokumenter\_Studier\Prosjekt\Prosjektoppgave\src\11thSPE-CSP\geometries\11AFiles";
        elseif strcmp(simcase.username, 'kholme')
            geometriesFolder = '/home/shomec/k/kholme/Documents/Prosjektoppgave/src/11thSPE-CSP/geometries/11AFiles';
        end
        matFile = fullfile(geometriesFolder, ['spe11a_ref', num2str(refinement_factor) ,'_grid.mat']);
        mFile = fullfile(geometriesFolder, ['spe11a_ref', num2str(refinement_factor), '.m']);
        if ~isfile(matFile) && ~isfile(mFile)
            error([matFile,' and ', mfile, ' not found']);
        elseif ~isfile(matFile) && isfile(mFile)
            G = gmshToMRST(mFile);
            save(matFile, "G")
        end
        load(matFile);       
        
        G = removeCells(G, G.cells.tag == 7);%try to remove 0 perm cells
        G.cells.tag = G.cells.tag(G.cells.tag ~= 7);
        G.cells.indexMap = (1:G.cells.num)';
        if opt.dim == 3
            G = makeLayeredGrid(G, 0.01);
            G = computeGeometry(G);
        end
        G = RotateGrid(G);%rotategrid to Z axis

    elseif ~isempty(simcase.deck) %use deck if present
        G = initEclipseGrid(simcase.deck);
    end
    G = computeGeometry(G);
    assert(checkGrid(G) == true);
end