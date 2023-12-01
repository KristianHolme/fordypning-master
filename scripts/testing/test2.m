clear all
close all
%%

plotToolbar(G, state.rs);view(0,0);
dmax = max(state.rs);
dmin = min(state.rs);
colormap(Seismic(dmin, dmax))

%%
simcase = Simcase('SPEcase', 'B', 'gridcase', '5tetRef2', 'deckcase', 'RS', 'usedeck', true);
[states, ~, ~] = simcase.getSimData;
state = states{25};
G = simcase.G;
cellV = faceFlux2cellVelocity(G, state.flux(:, 2));
plotCellData(G, cellV(:, 1)), view(0,0); colormap('jet')
%% Regen semigrid
G = genHybridGrid('nx', 220, 'nz', 150, 'density', 0.5, 'savegrid', true);
plotCellData(G, G.cells.tag);

%%
SPEcase = 'B';
gridcase = 'struct840x120';%193x83
simcase = Simcase('SPEcase', SPEcase, 'gridcase', gridcase, 'usedeck', true, 'deckcase', 'RS');
G = simcase.G;
plotGrid(G);view(0,0);
axis equal;axis tight;
%%
G = genHybridGrid('nx', 260, 'nz', 120, 'density', 0.3, 'version', 'B');
plotGrid(G, 'facealpha', 0);


%% Find pressure at top
rho = @(p) model.fluid.rhoOS/model.fluid.bO(p, 0, 1);
equil = ode23(@(z, p) 9.81 .*rho(p), [900, 0], 300*barsa); %gives pressure at top is 2.0754e+07
equil = ode23(@(z, p) 9.81 .*rho(p), [0, sort(unique(G.cells.centroids(:, 3)'))], 2.0754e+07);
z_values = equil.x;
pressure_values = equil.y;
pressure_interp_func = @(z) interp1(z_values, pressure_values, z, 'linear');


%% Plot porosity
gridcase = '5tetRef2';
simcase = Simcase('gridcase', gridcase);
figure
plotCellData(simcase.G, simcase.rock.poro);view(0,0);axis tight;axis equal;
%% Test bufferVolume
gridcase = '5tetRef2';
simcase = Simcase('SPEcase', 'B', 'gridcase', gridcase);
G = simcase.G;
figure
plotCellData(G, G.cells.volumes);view(0,0);
title("before")

eps = 1e-10;
G = addBufferVolume(G, simcase.rock, 'eps', eps);
figure
plotCellData(G, G.cells.volumes);view(0,0);
title("After")
%%
plotToolbar(simcase.G, simcase.G);view(0,0);
%% Testing i simulateschedule
figure
plotCellData(model.G, state.FlowProps.ComponentPhaseMass{2,2});view(0,0);

%% gen Hybridgrid
nx = 203;
nz = 72;
dens = 0.3;
genHybridGrid('nx', nx, 'nz', nz, 'density', dens, 'savegrid', true)

%%
[grdecl, unrec] = readGRDECL('deck/CSP11A.GRDECL');
grdecl.COORD(1:3:end) = grdecl.COORD(1:3:end)*3000;
grdecl.COORD(2:3:end) = grdecl.COORD(2:3:end)*100;
grdecl.COORD(3:3:end) = grdecl.COORD(3:3:end)*1000;
grdecl.ZCORN = grdecl.ZCORN*1000;
writeGRDECL(grdecl, 'deck/CSP11B.GRDECL');