clear all
close all
%% Plot porosity
gridcase = '5tetRef2';
simcase = Simcase('gridcase', gridcase);
figure
plotCellData(simcase.G, simcase.rock.poro);view(0,0);axis tight;axis equal;
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