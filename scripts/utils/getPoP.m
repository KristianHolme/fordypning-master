function data = getPoP(simcase, steps, popcell)
    dirName       = fullfile(simcase.dataOutputDir, simcase.casename);
    filename      = fullfile(dirName, 'PoP');
    if exist([filename, '.mat'], "file")
        disp("loading data...")
        load(filename)
    else
        disp("calculating data...")
        maxsteps = numel(simcase.schedule.step.val);

        popcells = simcase.getPoPCells;
        P1 = simcase.getCellData('pressure', 'cellIx', popcells(1));
        P2 = simcase.getCellData('pressure', 'cellIx', popcells(2));
        completedata = {P1, P2};
        
        save(filename, "completedata")
    end
    data = completedata{popcell}(1:steps);
end