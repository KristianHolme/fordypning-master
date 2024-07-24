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
        if simcase.jutulThermal
            maxsteps = 210;
        else
            maxsteps = numel(simcase.schedule.step.val);
        end
        sealingcells = G.cells.tag == 1;
        [states, ~, ~] = simcase.getSimData;
        typeParts = strsplit('FlowProps.ComponentTotalMass', '.');
        if simcase.jutul || simcase.jutulThermal
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
                adjustmentfactor = 1e-2;%For SPE11A only; 2D case is 1m deep (not 1 cm), need to divide by 100 to get comparable (actual) mass
            else
                adjustmentfactor = 1;
            end
            if simcase.jutul || simcase.jutulThermal
                completedata(it) = sum(fulldata(sealingcells, 2))*adjustmentfactor;
            else
                completedata(it) = sum(fulldata{2}(sealingcells))*adjustmentfactor;
            end
        end
        if savedata
            save(filename, "completedata");
        end
        % data = completedata(1:min(steps, numStates));
    end
    data = completedata(1:steps);
    
end