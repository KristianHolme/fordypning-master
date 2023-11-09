clear all
close all
%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh nfvm mpfa
mrstVerbose off
%%
% deckcases = {'RS', 'IMMISCIBLE', 'RS_3PH','RSRV', 'pyopm-Finer', 'pyopm-Coarser'};


%%
% gridcases = {'5tetRef10', '5tetRef8', '5tetRef6', '5tetRef4', '5tetRef2','struct220x90', 'struct340x150',
% 'semi188x38_0.3','semi203x72_0.3',  'semi263x154_0.3'};
% schedulecases = {'simple-coarse', 'simple-std'};

gridcases = {'5tetRef2-2D'};
schedulecases = {''};%defaults to schedule from deck
deckcases = {'RS'}; % can be changed to 'IMMISCIBLE'
% pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
pdiscs = {'hybrid-ntpfa'};
uwdiscs = {''};
disc_prio = 1;%1 means tpfa prio when creating faceblocks for hybrid discretization, 2 means prio other method
tagcase = '';

resetData = false;
resetAssembly = false;
do.plotStates = true;
do.multiphase = false;
useJutulIfPossible = false;
direct_solver = false; %may not be respected if backslashThreshold is not met

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
                    simcase = Simcase('deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
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
                    if do.plotStates
                        simcase.plotStates('lockCaxis', false);
                        % clim([0 6e-7]);
                    end
                end
            end
        end
    end
end
disp(timings)
