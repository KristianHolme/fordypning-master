function data = getCealingCO2(simcase, steps)
    G = simcase.G;
    cealingcells = G.cells.tag == 1;
    [states, ~, ~] = simcase.getSimData;
    typeParts = strsplit('FlowProps.ComponentTotalMass', '.');
    data = zeros(steps, 1);
    for it = 1:steps
        fulldata = getfield(states{it}, typeParts{:});

        data(it) = sum(fulldata{2}(cealingcells));

    end
end