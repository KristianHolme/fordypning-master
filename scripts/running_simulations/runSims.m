clear all
close all

%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics...
    deckformat gmsh nfvm mpfa msrsb coarsegrid jutul
mrstVerbose on
%%
% deckcases = {'RS', 'IMMISCIBLE', 'RS_3PH','RSRV', 'pyopm-Finer', 'pyopm-Coarser'};


%%
% gridcases = {'5tetRef10', '5tetRef8', '5tetRef6', '5tetRef4', '5tetRef2',, 'struct193x83', 'struct220x90', 'struct340x150',
% 'semi188x38_0.3','semi203x72_0.3',  'semi263x154_0.3'};
% SPEcase = 'A';
% gridcases = {'5tetRef10'};
% pdiscs = {'hybrid-ntpfa'};
% deckcases = {'RS'};
% schedulecases = {'simple-coarse', 'simple-std'};

SPEcase = 'B';
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
gridcases = {'cart_ndg_cut_PG_130x62'};

% SPEcase = 'C'; %some grids for SPE11C
% gridcases = {'horz_ndg_cut_PG_5', 'struct50x50x50', 'cart_ndg_cut_PG_50x50x50'};
% gridcases = {'cart_ndg_cut_PG_50x50x50', 'cart_ndg_cut_PG_100x100x100'};


% pdiscs = {''};
% pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
pdiscs = {'', 'hybrid-avgmpfa', 'indicator-hybrid-avgmpfa'};

schedulecases = {''};%defaults to schedule from deck
deckcases = {'B_ISO_C'}; %B_ISO_C
uwdiscs = {''}; % '' means SPU, 'WENO' means WENO transport discretizations
disc_prio = 1;%1 means tpfa prio when creating faceblocks for hybrid discretization, 2 means prio other method
tagcase = '';%some options: normalRock, bufferMult, deckrock, allcells, diagperm, gdz-shift, CPPD

Jutul               = false; %use Jutul for simulations. Only works for TPFA
jutulThermal        = false;
resetData           = false; %Start simulation at beginning, ignoring saved steps
resetAssembly       = false; %ignore stored preprocessing computations for consistent discretizations
do.plotStates       = false; %plot results of simulations using plotToolBar
do.plotFlux         = false; %plots flux
do.plotFacies       = false;
do.runSimulation    = false;  %run simulation
do.plotOrthErr      = false; %plot cellwise K-orthogonality indicator
do.dispTime         = true; %display simulation time
direct_solver       = false; % use direct solver instead of better iterative solvers like AMG/CPR. May not be respected if backslashThreshold is not met
mrstVerbose off;

%Does simulation/plotting for all combinations of parameters specified above
stats = {};
timings = struct();
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
                        timingname = replace(simcase.casename, '=', '_');
                        timingname = replace(timingname, '-', '_');
                        timingname = replace(timingname, '.', '_');
                        timings.(timingname) = time;
                    end
                    if do.dispTime
                        fprintf('Timing: %s: %0.2f\n', simcase.casename, simcase.getWallTime);
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
                    % G = simcase.G;
                    % [inj1, inj2] = getinjcells(simcase);
                    % disp(simcase.gridcase);
                    % disp(G.cells.tag([inj1;inj2]))
                    % figure('Name',simcase.gridcase);
                    % plotToolbar(G, G.cells.tag);view(0,0)
                    % plotGrid(G, [inj1;inj2]);

                    
                    % stats{end+1,1} =  simcase.gridcase;
                    % states = simcase.getSimData;
                    % totco2 = sum(states{301}.FlowProps.ComponentTotalMass{2});
                    % stats{end,2} = totco2;
                end
            end
        end
    end
end
if do.dispTime
    disp(timings);
end
% disp(stats);
