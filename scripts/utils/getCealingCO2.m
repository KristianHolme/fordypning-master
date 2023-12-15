function data = getCealingCO2(simcase, steps)
    G = simcase.G;
    dirName       = fullfile(simcase.dataOutputDir, simcase.casename);
    filename      = fullfile(dirName, 'sealingCO2');
    if exist([filename, '.mat'], "file")
        disp("loading data...")
        load(filename)
    else
        disp("calculating data...")
        maxsteps = numel(simcase.schedule.step.val);
        cealingcells = G.cells.tag == 1;
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