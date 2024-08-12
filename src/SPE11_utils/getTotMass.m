function totMass = getTotMass(states, step, simcase)
if simcase.jutul
    totMass = states{step}.TotalMasses(:,2);
else
    totMass = states{step}.FlowProps.ComponentTotalMass{2};
end
end