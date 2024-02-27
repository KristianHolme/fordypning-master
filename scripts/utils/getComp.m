function data = getComp(simcase, steps, submeasure, box, varargin)
    opt = struct('resetData', false);
    opt = merge_options(opt, varargin{:});
    dirName       = fullfile(simcase.dataOutputDir, simcase.casename);
    filename      = fullfile(dirName, ['comp', box]);
    if exist([filename, '.mat'], "file") && ~opt.resetData
        disp("loading data...")
        load(filename)
    else
        disp("calculating data...")
        maxsteps = numel(simcase.schedule.step.val);
        boxWeights = getCSPBoxWeights(simcase.G, box, simcase.SPEcase);
        [states, ~, ~] = simcase.getSimData;

        completedata = zeros(maxsteps, 4);
        for it = 1:maxsteps
            flowprops = states{it}.FlowProps;
            totalmass = flowprops.ComponentTotalMass{2};
            phasemass = flowprops.ComponentPhaseMass;
            Co2RelPerm = flowprops.RelativePermeability{2};
            %submeasurable 1
            freeco2 = phasemass{2,2};
            mobileCells = Co2RelPerm > 0;
            completedata(it, 1) = sum(freeco2.*(boxWeights .* mobileCells));
            %submeasure 2
            completedata(it, 2) = sum(freeco2.*(boxWeights .* ~mobileCells));
            %submeasure 3
            dissolvedco2 = phasemass{2,1};
            completedata(it, 3) = sum(dissolvedco2 .* boxWeights);
            %submeasure 4
            sealCells = simcase.G.cells.tag == 1;
            completedata(it, 4) = sum(totalmass.*(boxWeights .* sealCells));
        end
        if simcase.G.griddim == 2
            adjustmentfactor = 1e-2;%2D case is like 1m deep, need to divide by 100 to get comparable (actual) mass
        else
            adjustmentfactor = 1;
        end
        completedata = completedata*adjustmentfactor;
        save(filename, "completedata")
    end
    data = completedata(1:steps, submeasure);
end
