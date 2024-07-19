clear all
close all

mrstVerbose off
%%
% deckcases = {'RS', 'IMMISCIBLE', 'RS_3PH','RSRV', 'pyopm-Finer', 'pyopm-Coarser'};



% gridcases = {'5tetRef10', '5tetRef8', '5tetRef6', '5tetRef4', '5tetRef2',, 'struct193x83', 'struct220x90', 'struct340x150',
% 'semi188x38_0.3','semi203x72_0.3',  'semi263x154_0.3'};
% SPEcase = 'A';
% gridcases = {'5tetRef10'};
% pdiscs = {'ntpfa'};
% deckcases = {'RS'};
% schedulecases = {'simple-coarse', 'simple-std'};

% SPEcase = 'B';
% gridcases = {'cp_pre_cut_130x62', 'pre_cut_130x62', '5tetRef3-stretch', 'struct130x62', ''};%pre_cut_130x62, 5tetRef1.2
% gridcases = {'', 'struct130x62', 'horz_pre_cut_PG_130x62', 'cart_pre_cut_PG_130x62', 'cPEBI_130x62'};
% gridcases = {'horz_ndg_cut_PG_220x110', 'cart_ndg_cut_PG_220x110', 'cPEBI_220x110'};
% gridcases = {'horz_ndg_cut_PG_130x62', 'horz_pre_cut_PG_130x62'};
% gridcases = {'cart_ndg_cut_PG_130x62', 'cart_ndg_cut_FPG_130x62'};
% gridcases = {'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117'};
% gridcases = {'horz_ndg_cut_PG_130x62', 'horz_ndg_cut_PG_220x110', 'horz_ndg_cut_PG_819x117'};
% gridcases = {'struct819x117', 'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117'};
% gridcases = {'', 'struct130x62', 'horz_ndg_cut_PG_130x62', 'cart_ndg_cut_PG_130x62'};
% gridcases = {'cPEBI_819x117', '5tetRef0.31'};
% gridcases = {'gq_pb0.19'};
% gridcases = {'5tetRef0.31'};
% gridcases = {'struct130x62'};
% gridcases = {'cart_ndg_cut_PG_1638x234', 'cart_ndg_cut_PG_2640x380', 'horz_ndg_cut_PG_1638x234'};
% gridcases = {'cart_ndg_cut_PG_130x62'};
% gridcases = {'horz_ndg_cut_PG_130x62'};
% gridcases = {'cart_ndg_cut_PG_819x117'};

SPEcase = 'C'; %some grids for SPE11C
% gridcases = {'horz_ndg_cut_PG_5', 'struct50x50x50', 'cart_ndg_cut_PG_50x50x50'};
% gridcases = {'cart_ndg_cut_PG_50x50x50', 'cart_ndg_cut_PG_100x100x100'};
gridcases = {'tet_zx10-M'};
% gridcases = {'tet_zx10-F3'};
% gridcases = {'flat_tetra_subwell_zx5'};
% gridcases = {'flat_tetra_subwell'};
% gridcases = {'flat_tetra'};
% gridcases = {'tetra_transfault_500x500x20'};
% gridcases = {'horz_ndg_cut_PG_50x50x50'};

pdiscs = {''};
% pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
% pdiscs = {'', 'hybrid-avgmpfa', 'ntpfa'};

schedulecases = {''};%defaults to schedule from deck
deckcases = {'B_ISO_C'}; %B_ISO_C
uwdiscs = {''}; % '' means SPU, 'WENO' means WENO transport discretizations
disc_prio = 1;%1 means tpfa prio when creating faceblocks for hybrid discretization, 2 means prio other method
tagcase = '';%some options: normalRock, bufferMult, deckrock, allcells, diagperm, gdz-shift, CPPD

Jutul               = false; %use Jutul for simulations. Only works for TPFA
jutulThermal        = false;

resetData           = false; %Start simulation at beginning, ignoring saved steps
resetAssembly       = false; %ignore stored preprocessing computations for consistent discretizations
do.plotStates       = false;  %plot results of simulations using plotToolBar
do.plotFlux         = false; %plots flux
do.plotFacies       = false;
do.runSimulation    = false; %run simulation
do.plotOrthErr      = false; %plot cellwise K-orthogonality indicator'
do.plothybridblocks = false;
do.dispTime         = false;  %display simulation time
direct_solver       = false; %use direct solver instead of better iterative solvers like AMG/CPR. May not be respected if backslashThreshold is not met
% mrstVerbose off;

%Does simulation/plotting for all combinations of parameters specified above
stats = {};
timings = [];
for ideck = 1:numel(deckcases)
    deckcase = deckcases{ideck};
    for igrid = 1:numel(gridcases)
        gridcase = gridcases{igrid};
        for ischedule = 1:numel(schedulecases)
            schedulecase = schedulecases{ischedule};
            for ipdisc = 1:numel(pdiscs)
                pdisc = pdiscs{ipdisc};
                for iuwdisc = 1:numel(uwdiscs)
                    uwdisc = uwdiscs{iuwdisc};
                    simcase = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                                    'schedulecase', schedulecase, 'tagcase', tagcase, ...
                                    'pdisc', pdisc, 'uwdisc', uwdisc, 'jutul', Jutul, 'jutulThermal', jutulThermal);
                    if do.runSimulation
                        [ok, status, time] = runSimulation(simcase, 'resetData', resetData, 'Jutul', Jutul, ...
                                            'direct_solver', direct_solver, 'prio', disc_prio, 'resetAssembly', resetAssembly);
                        disp(['Done with: ', simcase.casename]);
                    end
                    if do.dispTime
                        timingname = replace(simcase.casename, '=', '_');
                        timingname = replace(timingname, '-', '_');
                        timingname = replace(timingname, '.', '_');
                        time = simcase.getWallTime;
                        timings(end+1) = time;
                        fprintf('Timing: %s: %0.2f\n', simcase.casename, time);
                    end
                    if do.plotStates
                        simcase.plotStates('lockCaxis', false);
                        % clim([0 6e-7]);
                    end
                    if do.plotFlux
                        simcase.plotFlux();
                    end
                    if do.plotOrthErr
                        simcase.plotErr('plotHistogram', true, 'resetData', true);
                    end
                    if do.plotFacies
                        figure;
                        plotToolbar(simcase.G, simcase.G);view(0,0)
                    end
                    G = simcase.G;
                    n = gridCellNodes(G, 1:G.cells.num);
                    % Extract node numbers from the first column
                    nodes = n;
                    
                    % Find the unique node numbers
                    unique_nodes = unique(nodes);
                    
                    % Count occurrences of each unique node
                    % node_counts = histcounts(nodes, [unique_nodes; max(unique_nodes)+1]);
                    % f = figure;
                    % maxCellsPerNode = max(node_counts);
                    % histogram(node_counts,(1:(maxCellsPerNode+1))-0.5);
                    % grid;
                    % title(simcase.gridcase, 'Interpreter','none');
                    % xlabel('number of cells sharing same node');
                    % tightfig();
                    % saveas(f, ['./../plots/cellsPerNode', simcase.gridcase, '.png']);


                    %plot faces per cell and nodes per face histograms
                    % figure
                    % histogram(diff(simcase.G.cells.facePos));
                    % title(simcase.gridcase, 'Interpreter','none');
                    % xlabel('# faces per cell');
                    % 
                    % figure
                    % histogram(diff(simcase.G.faces.nodePos));
                    % title(simcase.gridcase, 'Interpreter','none');
                    % xlabel('# nodes per face');
                end
            end
        end
        if do.plothybridblocks
            [~, ~, fwerr] = simcase.computeStaticIndicator;
            [~, cellblocks] = getFaceBlocksFromIndicator(simcase.G, 'cellError', fwerr);
            plotHybridCellblocks(simcase.G, cellblocks);
        end
    end
end
if do.dispTime
    disp(timings);
end
% disp(stats);
