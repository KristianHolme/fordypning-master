function data = getSealingCO2(simcase, steps, varargin)
    opt = struct('resetData', false);
    opt = merge_options(opt, varargin{:});

    G = simcase.G;
    dirName       = fullfile(simcase.dataOutputDir, simcase.casename);
    filename      = fullfile(dirName, 'sealingCO2');
    if exist([filename, '.mat'], "file") && ~opt.resetData
        disp("loading data...")
        completedata = load(filename).completedata;
    else
        savedata = true;
        disp("calculating data...")
        maxsteps = numel(simcase.schedule.step.val);
        cealingcells = G.cells.tag == 1;
        [states, ~, ~] = simcase.getSimData;
        typeParts = strsplit('FlowProps.ComponentTotalMass', '.');
        if simcase.jutul
            typeParts = {'TotalMasses'};
        end
        
        numStates = numelData(states);
        if numStates < maxsteps
            savedata = false;
        end
        completedata = NaN(maxsteps, 1);
        maxsteps = min(maxsteps, numStates);
        for it = 1:maxsteps
            %break if we dont have any data
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
        if savedata
            save(filename, "completedata");
        end
        % data = completedata(1:min(steps, numStates));
    end
    data = completedata(1:steps);
    
end