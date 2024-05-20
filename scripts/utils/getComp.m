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
        if simcase.jutulThermal
            allsteps = 210;
        else
            allsteps = numel(simcase.schedule.step.val);
        end
        completedata = NaN(allsteps, 4);
        boxWeights = getCSPBoxWeights(simcase.G, box, simcase.SPEcase);
        [states, ~, ~] = simcase.getSimData;
        maxsteps = min(allsteps, numelData(states));

        
        for it = 1:maxsteps
            if simcase.jutulThermal
                state = states{it};
                totalmass = state.TotalMasses(:,2);
                
                rho = state.PhaseMassDensities;
                X = state.LiquidMassFractions;
                Y = state.VaporMassFractions;
                s = state.s;
                vol = simcase.rock.poro .* simcase.G.cells.volumes;
                Co2RelPerm = state.RelativePermeabilities(:,2);
                freeco2 = vol .* s(:,2) .* rho(:,2) .* Y(:,2);
                dissolvedco2 = vol .* s(:,1) .* rho(:,1) .* X(:,2);
            else
                flowprops = states{it}.FlowProps;
                totalmass = flowprops.ComponentTotalMass{2};
                phasemass = flowprops.ComponentPhaseMass;
                Co2RelPerm = flowprops.RelativePermeability{2};
                freeco2 = phasemass{2,2};
                dissolvedco2 = phasemass{2,1};
            end
            %submeasurable 1, mobile
            mobileCells = Co2RelPerm > 1e-12;
            % mobileCells2 = Co2RelPerm > 1e-12;
            % difference = sum(mobileCells2 ~= mobileCells);    
            completedata(it, 1) = sum(freeco2.*(boxWeights .* mobileCells));
            %submeasure 2, immobile
            completedata(it, 2) = sum(freeco2.*(boxWeights .* ~mobileCells));
            %submeasure 3
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
        if maxsteps == allsteps
            save(filename, "completedata")
        end
    end
    data = completedata(1:steps, submeasure);
end
