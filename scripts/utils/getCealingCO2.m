function data = getCealingCO2(simcase, steps)
    G = simcase.G;
    cealingcells = G.cells.tag == 1;
    [states, ~, ~] = simcase.getSimData;
    typeParts = strsplit('FlowProps.ComponentTotalMass', '.');
    data = zeros(steps, 1);
    for it = 1:steps
        fulldata = getfield(states{it}, typeParts{:});
        if G.griddim == 2
            adjustmentfactor = 1e-2;%2D case is like 1m deep, need to divide by 100 to get comparable (actual) mass
        else
            adjustmentfactor = 1;
        end
        data(it) = sum(fulldata{2}(cealingcells))*adjustmentfactor;
    end
end