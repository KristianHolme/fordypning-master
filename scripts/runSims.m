clear all
close all
%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh
mrstVerbose off
%%
% decks = {'RS', 'IMMISCIBLE', 'RS_3PH','RSRV'};


%%
% gridcases = {'tetRef10', 'tetRef8', 'tetRef6', 'tetRef4', 'tetRef2','struct220x90'};
% schedulecases = {'simple-coarse', 'simple-std'};

gridcases = {'tetRef0.8'};
schedulecases = {''};
deckcases = {'RS'};
tagcase = '';

resetData = false;
do.plotStates = false;
do.multiphase = true;
useJutulIfPossible = false;
direct_solver = false;

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

            simcase = Simcase('deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                            'schedulecase', schedulecase, 'tagcase', tagcase);
            if do.multiphase
                [ok, status, time] = solveMultiPhase(simcase, 'resetData', resetData, 'Jutul', Jutul, ...
                                    'direct_solver', direct_solver);
                disp(['Done with: ', simcase.casename]);
                timingname = replace(simcase.casename, '=', '_');
                timingname = replace(timingname, '-', '_');
                timings.(timingname) = time;
            end
            if do.plotStates
                simcase.plotStates
            end
        end
    end
end

