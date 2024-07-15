function G = setupGrid(simcase, varargin)
    opt = struct('extra', true);
    opt = merge_options(opt, varargin{:});
    sliceForBuffer = false;
    gridcase = simcase.gridcase;
    specase = lower(simcase.SPEcase);
    if contains(gridcase, 'stretch')
        stretch = true;
        specase = 'a';
    else
        stretch = false;
    end
    prefix = ['spe11', specase];
        
    if ~isempty(gridcase)
        gridFolder = fullfile(simcase.repoDir, 'grid-files');
        if contains(gridcase, 'gq')%gq_pb0.19
            ref = gridcase(6:end); %0.19
            ref = replace(ref, '.', '_');
            alg = gridcase(4:5);

            mFile = fullfile(gridFolder, [prefix, '_ref', ref, '_alg', alg, '.m']);
            matFile = fullfile(gridFolder, [prefix, '_ref', ref, '_alg', alg, '_grid.mat']);

            if ~isfile(matFile) && ~isfile(mFile)
                error([matFile,' and ', mFile, ' not found']);
            elseif ~isfile(matFile) && isfile(mFile)
                G = gmshToMRST(mFile);
                configFile = fileread('config.JSON');
                config = jsondecode(configFile);
                fn = fullfile(config.repo_folder, '..', '11thSPE-CSP','geometries', 'spe11a.geo');
                geodata = readGeo(fn, 'assignExtra', true); 
                G = tagbyFacies(G, geodata, 'scale', [3000, 1000, 1]);
                save(matFile, "G")
            end
            sliceForBuffer = true;

        elseif contains(gridcase, 'tetRef')
            meshAlg = str2double(gridcase(1));
            pattern = 'Ref(-?\d+\.?\d*)';
            match = regexp(gridcase, pattern, 'tokens');
            str_ref_factor = match{1}{1};
            refinement_factor = str2double(str_ref_factor);
            if mod(refinement_factor, 1) ~= 0
                str_ref_factor = replace(str_ref_factor, '.', '_');
            end
           
            matFile = fullfile(gridFolder, [prefix, '_ref', str_ref_factor, '_alg', num2str(meshAlg),'_grid.mat']);
            mFile = fullfile(gridFolder, [prefix, '_ref', str_ref_factor, '_alg', num2str(meshAlg), '.m']);
            if ~isfile(matFile) && ~isfile(mFile)
                error([matFile,' and ', mfile, ' not found']);
            elseif ~isfile(matFile) && isfile(mFile)
                G = gmshToMRST(mFile);
                save(matFile, "G")
            end
            sliceForBuffer = true;
                   
            
        elseif contains(gridcase, 'struct')
            resolution = replace(replace(gridcase, '-2D', ''), 'struct', ''); %format struct200x200
            matFile = fullfile(gridFolder, [prefix, '_struct', resolution ,'_grid.mat']);
            mFile = fullfile(gridFolder, [prefix, '_struct', resolution, '.m']);
            if ~isfile(matFile) && ~isfile(mFile)
                error([matFile,' and ', mFile, ' not found']);
            elseif ~isfile(matFile) && isfile(mFile)
                G = gmshToMRST(mFile);
                save(matFile, "G")
            end
            if contains(resolution, '8400') %really big case, all cells are small, so dont need extra small (?)
                sliceForBuffer = false;
            else
                sliceForBuffer = true;
            end
        elseif contains(gridcase, 'skewed3D')
            G = makeSkewed3D();
            return
        elseif contains(gridcase, 'semi')
            params = replace(replace(gridcase, '-2D', ''), 'semi', '');
            matFile = fullfile(gridFolder, [prefix, '_semi', params, '_grid.mat']);
            if strcmp(simcase.SPEcase, 'B')%stretch A-grid
                amatFile = fullfile(gridFolder, ['spe11a_semi', params, '_grid.mat']);
                load(amatFile)
                G = stretchGrid(rotateGrid(G));
                save(matFile, 'G');
            end
            
            if ~isfile(matFile)
                error([matFile, ' not found']);
            end
        elseif contains(gridcase, 'cp')
            matFile = fullfile('grid-files/cutcell/', [gridcase, '.mat']);
        elseif contains(gridcase, 'cut')
            gridFolder = 'grid-files/cutcell';
            pattern = '(\d+)x(\d+)x?(\d+)?$';
            tokens = regexp(gridcase, pattern, 'tokens');
            params = tokens{1};
            params = cellfun(@str2double, params);
            if numel(params) == 2 || (numel(params) == 3 & isnan(params(3)))
                matFile = [num2str(params(1)), 'x', num2str(params(2)), '_', simcase.SPEcase,'.mat'];
            elseif numel(params) == 3 & ~isnan(params(3))
                matFile = [num2str(params(1)), 'x', num2str(params(2)),'x', num2str(params(3)), '_', simcase.SPEcase,'.mat'];
            end
            if contains(gridcase, 'FPG')
                matFile = ['FPG_', matFile];
            elseif contains(gridcase, 'PG')
                matFile = ['PG_', matFile];
            end
            matFile = ['cutcell_', matFile];
            if contains(gridcase, 'pre')
                matFile = ['presplit_', matFile];
            end
            if contains(gridcase, 'ndg')
                matFile = ['nudge_', matFile];
            end
            if contains(gridcase, 'cart')
                matFile = ['cartesian_', matFile];
            elseif contains(gridcase, 'horz')
                matFile = ['horizon_', matFile];
            end
            if ~strcmp(simcase.SPEcase, 'A')
                matFile = ['buff_', matFile];
            end
            matFile = fullfile(gridFolder, matFile);
        elseif contains(gridcase, 'PEBI')
            gridFolder = 'grid-files/PEBI';
            gridfilename = [gridcase, '_', simcase.SPEcase, '.mat'];

            if ~strcmp(simcase.SPEcase, 'A')
                gridfilename = ['buff_', gridfilename];
            end
            matFile = fullfile(gridFolder, gridfilename);
        elseif contains(gridcase, 'transfault') 
            gridFolder = fullfile('./../../total-grids/', gridcase);
            gridfilename = 'G_SPE.mat';
            matFile = fullfile(gridFolder, gridfilename);
            if isfile(matFile)
                load(matFile);
            else
                origGridFile = fullfile(gridFolder, 'G_flipped.mat');
                load(origGridFile)
                G = transfaultTag(G);
                G = transfaultBufferSlice(G);
                G = transfaultGetBufferCells(G);
                save(matFile, "G")
            end

            return
        elseif contains(gridcase, 'flat_tetra')
            gridFolder = './../../total-grids/flat_tetra';
            if contains(gridcase, 'subwell')
                gridfilename = 'flat_tetra_subwell_SPE.mat';
            else
                gridfilename = [gridcase, '_SPE.mat'];
            end
            matFile = fullfile(gridFolder, gridfilename);
            if isfile(matFile)
                load(matFile);
            else
                origGridFile = fullfile(gridFolder, [gridcase, '.mat']);
                load(origGridFile)
                G = transfaultTag(G);
                G = transfaultBufferSlice(G, 'sliceOffset', 1);
                G = transfaultGetBufferCells(G);
                save(matFile, "G")
            end
            %check if we want to elongate in z direction to avoid flatness
            pattern = 'zx(\d+)'; % Regular expression pattern for "zx" followed by one or more digits

            matches = regexp(gridcase, pattern, 'tokens'); % Find matches and extract tokens
            
            if ~isempty(matches)
                z_scale = str2double(matches{1}{1}); % Convert the extracted token to a number
                G.nodes.coords(:,3) = G.nodes.coords(:,3)*z_scale;
                G = mcomputeGeometry(G);
            end
            return
        elseif contains(gridcase, 'cTwist') || contains(gridcase, 'cart')
            tets = contains(gridcase, 'tets');
            twist = contains(gridcase, 'wist');
            if endsWith(gridcase, '-C')
                nx = 10;
                ny = 10;
                nz = 4;
            elseif endsWith(gridcase, '-M')
                nx = 40;
                ny = 40;
                nz = 8;
            elseif endsWith(gridcase, '-F')
                nx = 80;
                ny = 80;
                nz = 16;
            end
            G = makecTwistGrid(nx, ny, nz, 'tets', tets, 'twist', twist, 'tag', gridcase);
            G = transfaultTag(G);
            G = transfaultBufferSlice(G);
            G = transfaultGetBufferCells(G);
            return
        end
        load(matFile);

        if simcase.griddim == 3
            if strcmp(simcase.SPEcase, 'A')
                depth = 0.01;
            else
                depth = 1.0;
            end
            if G.griddim ~=3
                G = makeLayeredGrid(G, 1);
                k  = G.nodes.coords(:, 3) > 0;
                G.nodes.coords(k, 3) = depth;
                G = computeGeometry(G);
                G.faces.tag = zeros(G.faces.num, 1);
            end
            if ~any(ismember(G.type, 'rotateGrid')) && ~(max(G.cells.centroids(:,3)) > 1000)
                G = rotateGrid(G);%rotateGrid to Z axis
            end
        end
        
        
    elseif ~isempty(simcase.deck) %use deck if present
        matFile = fullfile('grid-files/deck', [simcase.deckcase,'.mat']);
        if isfile(matFile)
            load(matFile);
        else
            G = initEclipseGrid(simcase.deck, 'usemex', true);
            G = computeGeometry(G);
            G = getBufferCells(G);
            G = addBoxWeights(G, 'SPEcase', simcase.SPEcase);
            % G.cells.indexMap = 1:G.cells.num;
            matFile = fullfile('grid-files/deck', [simcase.deckcase,'.mat']);
            if ~isfield(G.faces, 'tag')
                G.faces.tag = zeros(G.faces.num, 1);
            end
            
            if max(G.cells.volumes) > 100800
                return
            end
            % rock = setupRock(simcase, 'deck', true);
            G.cells.tag = simcase.deck.REGIONS.SATNUM(logical(simcase.deck.GRID.ACTNUM));
            save(matFile, 'G');
        end
    end
    
    if isfield(G, 'parent') %coarsegrid, this computation maybe superfluous??
        G = coarsenGeometry(G);
    else
        if mrstSettings('get', 'useMEX')
            G = mcomputeGeometry(G);
        else
            G = computeGeometry(G);
        end
        assert(all(G.cells.volumes > 0), 'negative volumes!')
    end

    

    if stretch
        G = stretchGrid(G);
    end

    if ~isfield(G.cells, 'tag') && opt.extra
        G.cells.tag = simcase.rock.regions.saturation;
        if max(simcase.rock.poro) > 1 %poro is adjusted instead of volume
            opt.buffer = false;
        end
    end

    if sliceForBuffer
        if min(G.cells.centroids(:,1)) > 0.6
            G = bufferSlice(G, SPEcase);
            G.faces.tag = zeros(G.faces.num, 1);
            save(matFile, 'G');
        end
    end

    if ~isfield(G, 'bufferCells')
        G = getBufferCells(G);
    end

    if ~isfield(G.cells, 'fractionInA')
        G = addBoxWeights(G, 'SPEcase', simcase.SPEcase);
    end
    
    testing = false;
    if (~isfield(G, 'reductionMatrix') ) & ~strcmp(simcase.SPEcase, 'C') %not yet implemented for C
        switch simcase.SPEcase
            case 'B'
                redNx = 840;
                redNy = 120;
            case 'A'
                redNx = 280;
                redNy = 120;
        end
        [M, Gr, report] = getReductionMatrix(G, redNx, redNy);
        G.reductionMatrix = M;
        G.reductionGrid = Gr;
        G.reductionReport = report;
        save(matFile, 'G');
    end



    if (~isempty(simcase.tagcase) && contains(simcase.tagcase, 'allcells')) 
        ;%dont remove cells
    else
        [G, cellmap] = removeCells(G, G.cells.tag == 7);%try to remove 0 perm cells
        % active = G.cells.tag ~= 7;
        G.cells.indexMap = cellmap;
        G.cells.tag = G.cells.tag(cellmap);
        [ismem, ind] = ismember(G.bufferCells, cellmap);
        G.bufferCells = ind(ismem);
        G.bufferFaces = [];
    end

    
    
    if ~checkGrid(G)
        warning("Grid does not pass checkgrid!")
    end
    % assert(checkGrid(G) == true);
end

function G = makeSkewed3D()
    G = cartGrid([41,20],[2, 1]);
    makeSkew = @(c) c(:,1) + .4*(1-(c(:,1)-1).^2).*(1-c(:,2));
    G.nodes.coords(:,1) = 2*makeSkew(G.nodes.coords);
    G.nodes.coords(:,1) = G.nodes.coords(:,1)*(2.8/4);
    G.nodes.coords(:,2) = G.nodes.coords(:,2)*(1.2);
    % G.nodes.coords = twister(G.nodes.coords);
    % G.nodes.coords(:,1) = 2*G.nodes.coords(:,1);
    
    G = makeLayeredGrid(G, 1);
    k = G.nodes.coords(:,3) > 0;
    G.nodes.coords(k,3) = 0.01;
    G = computeGeometry(G);
    G = rotateGrid(G);
    G = computeGeometry(G);
end
