function data = getFaultFluxes(simcase, steps, varargin)
    opt = struct('resetData', false);
    opt = merge_options(opt, varargin{:});

    
    dirName       = fullfile(simcase.dataOutputDir, simcase.casename);
    filename      = fullfile(dirName, 'faultflux.mat');
    if exist(filename, "file") && ~opt.resetData
        disp("loading data...")
        load(filename)
    else
        G = simcase.G;
        disp("calculating data...")
        maxsteps = numel(simcase.schedule.step.val);
        
        [states, ~, ~] = simcase.getSimData;
        % neighbors = G.faces.neighbors;
        % neighborTags = neighbors;
        % for i=1:2
        %     nonzeros = neighbors(:,i) ~= 0;
        %     neighborTags(nonzeros,i) = G.cells.tag(neighbors(nonzeros, i));
        % end
        % internal = (neighborTags(:,1) ~= 0) & (neighborTags(:,2) ~= 0);
        % % internal = simcase.model.operators.internalConn;
        % layerCrossingFaces = (neighborTags(:,1) ~= neighborTags(:,2)) & internal;
        layerCrossingFaces = layerCrossingFaces(G);
        completedata = NaN(maxsteps, 1);
        maxsteps = min(maxsteps, numelData(states));
        
        for it = 1:maxsteps
            allfluxes = states{it}.flux;
            fluxes = allfluxes(layerCrossingFaces,2);
            absfluxes = abs(fluxes);
            totabsflux = sum(absfluxes);
            completedata(it) = totabsflux;
        end
        save(filename, "completedata")
    end
    data = completedata(1:steps);

end