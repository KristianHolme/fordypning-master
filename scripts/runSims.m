clear all
close all

%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh nfvm mpfa msrsb coarsegrid
mrstVerbose off
%%
% deckcases = {'RS', 'IMMISCIBLE', 'RS_3PH','RSRV', 'pyopm-Finer', 'pyopm-Coarser'};


%%
% gridcases = {'5tetRef10', '5tetRef8', '5tetRef6', '5tetRef4', '5tetRef2',, 'struct193x83', 'struct220x90', 'struct340x150',
% 'semi188x38_0.3','semi203x72_0.3',  'semi263x154_0.3'};
% schedulecases = {'simple-coarse', 'simple-std'};

SPEcase = 'B';
% gridcases = {'cp_pre_cut_130x62', 'pre_cut_130x62', '5tetRef3-stretch', 'struct130x62', ''};%pre_cut_130x62, 5tetRef1.2
gridcases = {''};
schedulecases = {''};%defaults to schedule from deck
deckcases = {'B_ISO_SMALL'}; %B_ISO_SMALL
pdiscs = {'cc'};
uwdiscs = {''};
disc_prio = 1;%1 means tpfa prio when creating faceblocks for hybrid discretization, 2 means prio other method
tagcase = '';%normalRock

resetData           = false;
resetAssembly       = true;
do.plotStates       = false;
do.plotFlux         = false;
do.multiphase       = true;
do.dispTime         = false;
useJutulIfPossible  = false;
direct_solver       = false; %may not be respected if backslashThreshold is not met

timings = struct();
for ideck = 1:numel(deckcases)
    deckcase = deckcases{ideck};
    if strcmp(deckcase, 'IMMISCIBLE') && useJutulIfPossible
        Jutul = true;
    else
        Jutul = false;
    end
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
                                    'pdisc', pdisc, 'uwdisc', uwdisc);
                    if do.multiphase
                        [ok, status, time] = solveMultiPhase(simcase, 'resetData', resetData, 'Jutul', Jutul, ...
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
                end
            end
        end
    end
end
disp(timings)
