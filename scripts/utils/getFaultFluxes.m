function data = getFaultFluxes(simcase, steps, varargin)
    opt = struct('resetData', false);
    opt = merge_options(opt, varargin{:});

    G = simcase.model.G;
    dirName       = fullfile(simcase.dataOutputDir, simcase.casename);
    filename      = fullfile(dirName, 'faultflux.mat');
    if exist([filename, '.mat'], "file") && opt.resetData
        disp("loading data...")
        load(filename)
    else
        disp("calculating data...")
        maxsteps = numel(simcase.schedule.step.val);
        
        [states, ~, ~] = simcase.getSimData;
        neighbors = G.faces.neighbors;
        neighborTags = neighbors;
        for i=1:2
            nonzeros = neighbors(:,i) ~= 0;
            neighborTags(nonzeros,i) = G.cells.tag(neighbors(nonzeros, i));
        end
        internal = (neighborTags(:,1) ~= 0) & (neighborTags(:,2) ~= 0);
        % internal = simcase.model.operators.internalConn;
        layercrossingfaces = (neighborTags(:,1) ~= neighborTags(:,2)) & internal;

        completedata = zeros(maxsteps, 1);
        for it = 1:maxsteps
            allfluxes = states{it}.flux;
            fluxes = allfluxes(layercrossingfaces);
            absfluxes = abs(fluxes);
            totabsflux = sum(absfluxes);
            completedata(it) = totabsflux;
        end
        save(filename, "completedata")
    end
    data = completedata(1:steps);

end