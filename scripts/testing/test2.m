clear all
close all
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