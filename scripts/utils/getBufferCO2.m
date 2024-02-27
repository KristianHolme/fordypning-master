function data = getBufferCO2(simcase, steps, varargin)
    opt = struct('resetData', false);
    opt = merge_options(opt, varargin{:});
    G = simcase.G;
    dirName       = fullfile(simcase.dataOutputDir, simcase.casename);
    filename      = fullfile(dirName, 'BufferCO2');
    if exist([filename, '.mat'], "file") && ~opt.resetData
        disp("loading data...")
        load(filename)
    else
        disp("calculating data...")
        maxsteps = numel(simcase.schedule.step.val);
        if ~isfield(G, 'bufferCells')
            G = getBufferCells(G);
        end
        cealingcells = G.bufferCells;
        [states, ~, ~] = simcase.getSimData;
        typeParts = strsplit('FlowProps.ComponentTotalMass', '.');
        completedata = zeros(maxsteps, 1);
        for it = 1:maxsteps
            fulldata = getfield(states{it}, typeParts{:});
            if G.griddim == 2
                adjustmentfactor = 1e-2;%2D case is like 1m deep, need to divide by 100 to get comparable (actual) mass
            else
                adjustmentfactor = 1;
            end
            completedata(it) = sum(fulldata{2}(cealingcells))*adjustmentfactor;
        end
        save(filename, "completedata")
    end
    data = completedata(1:steps);
end