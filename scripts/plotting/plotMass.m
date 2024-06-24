function plotMass(simcase)
states = simcase.getSimData;
num_states = numelData(states);
totalCO2Mass = nan(num_states, 1);
for i = 1:num_states
    totalCO2Mass(i) = sum(states{i}.FlowProps.ComponentTotalMass{2});
end
plot(totalCO2Mass);
title("Total CO2 mass")
xlabel("timestep")
ylabel("CO2 [kg]");
grid();
end