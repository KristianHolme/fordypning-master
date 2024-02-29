function data = getSealingCO2(simcase, steps, varargin)
    opt = struct('resetData', false);
    opt = merge_options(opt, varargin{:});

    G = simcase.G;
    dirName       = fullfile(simcase.dataOutputDir, simcase.casename);
    filename      = fullfile(dirName, 'sealingCO2');
    if exist([filename, '.mat'], "file") && ~opt.resetData
        disp("loading data...")
        load(filename)
    else
        disp("calculating data...")
        maxsteps = numel(simcase.schedule.step.val);
        cealingcells = G.cells.tag == 1;
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
               completedata(it) = sum(fulldata(cealingcells, 2))*adjustmentfactor;
            else
                completedata(it) = sum(fulldata{2}(cealingcells))*adjustmentfactor;
            end
        end
        save(filename, "completedata")
    end
    data = completedata(1:steps);
end