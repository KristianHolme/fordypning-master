function data = getPoP(simcase, steps, popcell, varargin)
    opt = struct('resetData', false);
    opt = merge_options(opt, varargin{:});
    dirName       = fullfile(simcase.dataOutputDir, simcase.casename);
    filename      = fullfile(dirName, 'PoP');
    if exist([filename, '.mat'], "file") && ~opt.resetData
        disp("loading data...")
        load(filename)
    else
        disp("calculating data...")
        if ~isempty(simcase.jutulComp)
            maxsteps = 210;
        else
            maxsteps = numel(simcase.schedule.step.val);
        end

        popcells = simcase.getPoPCells;
        P1 = simcase.getCellData('pressure', 'cellIx', popcells(1));
        P2 = simcase.getCellData('pressure', 'cellIx', popcells(2));
        completedata = NaN(maxsteps, 2);
        completedata(1:numel(P1),1) = P1;
        completedata(1:numel(P2),2) = P2;
        % completedata = {P1, P2};
        if numel(P1)==maxsteps && numel(P2)==maxsteps
            save(filename, "completedata")
        end
    end
    data = completedata(1:steps, popcell);
end