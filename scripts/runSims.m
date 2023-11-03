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
% 'semi188x38_0.3', 'semi263x154_0.3'};
% schedulecases = {'simple-coarse', 'simple-std'};

gridcases = {'5tetRef1'};
schedulecases = {''};%defaults to schedule from deck
deckcases = {'RS'}; % can be changed to 'IMMISCIBLE'
% discmethods = {'', 'hybrid-avgmpfa-oo', 'hybrid-ntpfa-oo', 'hybrid-mpfa-oo'};
discmethods = {'hybrid-avgmpfa-oo'};
disc_prio = 1;%1 means tpfa prio when creating faceblocks for hybrid discretization
tagcase = '';

resetData = true;
do.plotStates = false;
do.multiphase = true;
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
            for idisc = 1:numel(discmethods)
                discmethod = discmethods{idisc};
                simcase = Simcase('deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                                'schedulecase', schedulecase, 'tagcase', tagcase, ...
                                'discmethod', discmethod);
                if do.multiphase
                    [ok, status, time] = solveMultiPhase(simcase, 'resetData', resetData, 'Jutul', Jutul, ...
                                        'direct_solver', direct_solver, 'prio', disc_prio);
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
disp(timings)
