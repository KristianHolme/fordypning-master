function G = generateQTorTGridMatlab(varargin)
    % GENERATEQTORTGRIDMATLAB Generate quad/triangle or triangle grid for SPE11
    %
    % Parameters:
    %   'refinementFactor' - Control mesh refinement (default: 1.0)
    %   'gridType'        - Either 'QT' or 'T' (default: 'QT')
    %   'SPEcase'         - Either 'A', 'B' or 'C' (default: 'A')
    %   'pythonPath'      - Path to Python executable (default: 'python')
    %   'Cdepth'          - Number of layers for case C (default: 50)
    %   'backgroundGridMap'- Generate background grid mapping (default: true)
    
    opt = struct('refinementFactor', 1.0, ...
                'gridType', 'QT', ...
                'SPEcase', 'A', ...
                'pythonPath', 'python', ...
                'Cdepth', 50, ...
                'backgroundGridMap', true);
    opt = merge_options(opt, varargin{:});
    

    % Validate grid type
    if ~ismember(opt.gridType, {'QT', 'T'})
        error('gridType must be either ''QT'' or ''T''');
    end
    
    % Validate SPE case
    if ~ismember(upper(opt.SPEcase), {'A', 'B', 'C'})
        error('SPEcase must be either ''A'' or ''B'' or ''C''');
    end

    %setup simcase with gridcase gq_pb0.19/ tetRef0.19
    if strcmp(opt.gridType, 'QT')
        gridcase = ['gq_pb', num2str(opt.refinementFactor)];
    elseif strcmp(opt.gridType, 'T')
        gridcase = ['5tetRef', num2str(opt.refinementFactor)];
    end

    if opt.SPEcase == 'C'
        tempSPECase = 'C';
        opt.SPEcase = 'B';
    else
        tempSPECase = opt.SPEcase;
    end
    simcase = Simcase('gridcase', gridcase, 'SPEcase', opt.SPEcase, 'tagcase', 'allcells');
    try
        G = setupGrid(simcase);
    catch E
        makeGmshFile(opt);
        G = setupGrid(simcase);
    end

    if strcmp(tempSPECase, 'C')
        % at this point we have a B grid
        opt.SPEcase = 'C';


        prefix = ['spe11', opt.SPEcase];
        ref = num2str(opt.refinementFactor);
        if strcmp(opt.gridType, 'QT')
            alg = 'pb';
        elseif strcmp(opt.gridType, 'T')
            alg = '5';
        end
        matFile = fullfile(simcase.repoDir, 'data/grid-files', [prefix, '_ref', ref, '_alg', alg, '_grid.mat']);
        if isfile(matFile)
            load(matFile, 'G');
        else
            configFile = fileread('config.JSON');
            config = jsondecode(configFile);
            fn = fullfile(config.geo_folder, 'spe11a.geo');
            geodata = readGeo(fn, 'assignExtra', true);

            %fn = 'C:\Users\holme\Documents\Prosjekt\Prosjektoppgave\src\11thSPE-CSP\geometries\spe11a.geo';

            G = addBackgroundGridMap(G, opt);

            G = removeLayeredGrid(G);
            layerthicknesses = [1; repmat(4998/opt.Cdepth, opt.Cdepth,1); 1];%one meter thickness for buffer volume in front and back
            G = makeLayeredGrid(G, layerthicknesses);
            G = mcomputeGeometry(G);
            G = rotateGrid(G);
            G = mcomputeGeometry(G);
            G = tagbyFacies(G, geodata, 'vertIx', 2);
            G.nodes.coords = bendSPE11C(G.nodes.coords);
            G = mcomputeGeometry(G);
            G = getBufferCells(G);
            G = finalizeBackgroundGridCaseC(G, opt);
            save(matFile, 'G');
        end
    else
        G = addBackgroundGridMap(G, opt);
    end
end 

function makeGmshFile(opt)
    % Build Python command
    scriptPath = fullfile(fileparts(mfilename('fullpath')), 'generateQTorTGrid.py');
    cmd = sprintf('%s "%s" %g %s %s', ...
        opt.pythonPath, ...
        scriptPath, ...
        opt.refinementFactor, ...
        opt.gridType, ...
        opt.SPEcase);

    % Run Python script
    [status, result] = system(cmd);
    if status ~= 0
        error('Failed to generate grid: %s', result);
    end
end