function G = setupGrid11A(simcase, varargin)
    opt = struct('refinement_factor', 1);
    opt = merge_options(opt, varargin{:});

    gridcase = simcase.gridcase;

    if ~isempty(gridcase)
        gridFolder = fullfile(simcase.repoDir, 'grid-files');
        if strcmp(simcase.user, 'holme')
            gridFolder = "C:\Users\holme\OneDrive\Dokumenter\_Studier\Prosjekt\Prosjektoppgave\src\grid-files";
        elseif strcmp(simcase.user, 'kholme')
            gridFolder = '/home/shomec/k/kholme/Documents/Prosjektoppgave/src/grid-files';
        end
        if contains(gridcase, 'tetRef')
            meshAlg = str2double(gridcase(1));
            refinement_factor = str2double(replace(gridcase(2:end), 'tetRef', ''));
            str_ref_factor = num2str(refinement_factor);
            if mod(refinement_factor, 1) ~= 0
                str_ref_factor = replace(str_ref_factor, '.', '_');
            end
           
            matFile = fullfile(gridFolder, ['spe11a_ref', str_ref_factor, '_alg', num2str(meshAlg),'_grid.mat']);
            mFile = fullfile(gridFolder, ['spe11a_ref', str_ref_factor, '_alg', num2str(meshAlg), '.m']);
            if ~isfile(matFile) && ~isfile(mFile)
                error([matFile,' and ', mfile, ' not found']);
            elseif ~isfile(matFile) && isfile(mFile)
                G = gmshToMRST(mFile);
                save(matFile, "G")
            end
                   
            
        elseif contains(gridcase, 'struct')
            resolution = replace(gridcase, 'struct', ''); %format struct200x200
            matFile = fullfile(gridFolder, ['spe11a_struct', resolution ,'_grid.mat']);
            mFile = fullfile(gridFolder, ['spe11a_struct', resolution, '.m']);
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
            params = replace(gridcase, 'semi', '');
            matFile = fullfile(gridFolder, ['spe11a_semi', params, '_grid.mat']);
            if ~isfile(matFile)
                
                error([matFile, ' not found']);
            end
        end
        load(matFile);
        G = removeCells(G, G.cells.tag == 7);%try to remove 0 perm cells
        G.cells.tag = G.cells.tag(G.cells.tag ~= 7);
        G.cells.indexMap = (1:G.cells.num)';
        if simcase.griddim == 3 && G.griddim ~=3
            G = makeLayeredGrid(G, 0.01);
            G = computeGeometry(G);
            G = RotateGrid(G);%rotategrid to Z axis
        elseif simcase.griddim == 2
            %make nodes 3D??no?
            % G.nodes.coords = [G.nodes.coords, zeros(size(G.nodes.coords, 1), 1)];
            % G = computeGeometry(G);
            % G.faces.normals = [G.faces.normals, zeros(size(G.faces.normals, 1), 1)];
            % return
        end
        


    elseif ~isempty(simcase.deck) %use deck if present
        G = initEclipseGrid(simcase.deck);
    end
    G = computeGeometry(G);
    assert(checkGrid(G) == true); %not satisfied for semigrid?
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