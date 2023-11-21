function G = setupGrid(simcase, varargin)
    opt = struct('buffer', true);
    opt = merge_options(opt, varargin{:});

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
        end
       load(matFile);
        G = removeCells(G, G.cells.tag == 7);%try to remove 0 perm cells
        G.cells.tag = G.cells.tag(G.cells.tag ~= 7);
        G.cells.indexMap = (1:G.cells.num)';
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
            if ~ismember(G.type, 'RotateGrid')
                G = RotateGrid(G);%rotategrid to Z axis
            end
        end
        
    elseif ~isempty(simcase.deck) %use deck if present
        G = initEclipseGrid(simcase.deck);
    end
    G = computeGeometry(G);
    if stretch
        G = StretchGrid(G);
    end
    if strcmp(simcase.SPEcase, 'B') && opt.buffer %add buffervolume
        G = addBufferVolume(G, simcase.rock);
    end
    assert(checkGrid(G) == true);
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