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
        bufferCells = G.bufferCells;
        [states, ~, ~] = simcase.getSimData;
        typeParts = strsplit('FlowProps.ComponentTotalMass', '.');
        if simcase.jutul
            typeParts = {'TotalMasses'};
        end
        completedata = zeros(maxsteps, 1);
        for it = 1:maxsteps
            fulldata = getfield(states{it}, typeParts{:});
            if G.griddim == 2
                adjustmentfactor = 1e-2;%2D case is like 1m deep, need to divide by 100 to get comparable (actual) mass
            else
                adjustmentfactor = 1;
            end
            if simcase.jutul
               completedata(it) = sum(fulldata(bufferCells, 2))*adjustmentfactor;
            else
                completedata(it) = sum(fulldata{2}(bufferCells))*adjustmentfactor;
            end
        end
        save(filename, "completedata")
    end
    data = completedata(1:steps);
end