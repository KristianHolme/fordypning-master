function G = setupGrid(simcase, varargin)
    opt = struct('buffer', true);
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
        
        if contains(gridcase, 'tetRef')
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
                error([matFile,' and ', mfile, ' not found']);
            elseif ~isfile(matFile) && isfile(mFile)
                G = gmshToMRST(mFile);
                save(matFile, "G")
            end
            sliceForBuffer = true;
        elseif contains(gridcase, 'skewed3D')
            G = makeSkewed3D();
            return
        elseif contains(gridcase, 'semi')
            params = replace(replace(gridcase, '-2D', ''), 'semi', '');
            matFile = fullfile(gridFolder, [prefix, '_semi', params, '_grid.mat']);
            if strcmp(simcase.SPEcase, 'B')%stretch A-grid
                amatFile = fullfile(gridFolder, ['spe11a_semi', params, '_grid.mat']);
                load(amatFile)
                G = StretchGrid(RotateGrid(G));
                save(matFile, 'G');
            end
            
            if ~isfile(matFile)
                error([matFile, ' not found']);
            end
        elseif contains(gridcase, 'cp')
            matFile = fullfile('grid-files/cutcell/', [gridcase, '.mat']);
        elseif contains(gridcase, 'cut')
            gridFolder = 'grid-files/cutcell';
            pattern = '(\d+)x(\d+)$';
            tokens = regexp(gridcase, pattern, 'tokens');
            params = tokens{1};
            params = cellfun(@str2double, params);
            matFile = [num2str(params(1)), 'x', num2str(params(2)), '_', simcase.SPEcase,'.mat'];
            if contains(gridcase, 'PG')
                matFile = ['PG_', matFile];
            else
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
        end
        load(matFile);
        if ~isempty(simcase.tagcase) && contains(simcase.tagcase, 'allcells')
            %dont remove cells
        else
            [G, cellmap] = removeCells(G, G.cells.tag == 7);%try to remove 0 perm cells
            G.cells.tag = G.cells.tag(G.cells.tag ~= 7);
            G.cells.indexMap = (1:G.cells.num)';
        end
        if simcase.griddim == 3
            if strcmp(simcase.SPEcase, 'A')
                depth = 0.01;
            else
                depth = 1.0;
            end
            if G.griddim ~=3
                G = makeLayeredGrid(G, depth);
                G = computeGeometry(G);
            end
            if ~any(ismember(G.type, 'RotateGrid')) && ~(max(G.cells.centroids(:,3)) > 1000)
                G = RotateGrid(G);%rotategrid to Z axis
            end
        end
        
    elseif ~isempty(simcase.deck) %use deck if present
        G = initEclipseGrid(simcase.deck);
        G = computeGeometry(G);
        if max(G.cells.volumes) > 100800
            return
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
        G = StretchGrid(G);
    end
    
    if strcmp(simcase.SPEcase, 'B') && opt.buffer %add buffervolume
        if ~isfield(G.cells, 'tag')
            G.cells.tag = simcase.rock.regions.saturation;
            if max(simcase.rock.poro) > 1 %poro is adjusted instead of volume
                opt.buffer = false;
            end
        end
        if opt.buffer
            if sliceForBuffer
                [G, simcase] = bufferSlice(G, simcase);
            end
            G = addBufferVolume(G, simcase.rock,'verbose', true);
        end
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
    
    G = makeLayeredGrid(G, 0.01);
    G = computeGeometry(G);
    G = RotateGrid(G);
    G = computeGeometry(G);
end
