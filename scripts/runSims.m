clear all
close all
%%
mrstModule add prosjektOppgave
%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat
%%
deckcases = {'RS', 'IMMISCIBLE', 'RS_3PH','RSRV'};


%%
% gridcases = {'tetRef10', 'tetRef8', 'tetRef6', 'tetRef4', 'tetRef2'};
% schedulecases = {'simple-coarse', 'simple-std'};

gridcases = {'tetRef10'};
schedulecases = {'simple-coarse'};
deckcases = {'IMMISCIBLE'};

resetData = false;
do.plotStates = false;
do.multiphase = true;
useJutulIfPossible = false;

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
                            'schedulecase', schedulecase);
            if do.multiphase
                [ok, status, time] = solveMultiPhase(simcase, 'resetData', resetData, 'Jutul', Jutul);
                timings.(simcase.deckcase) = time;
            end
            if do.plotStates
                simcase.plotStates
            end
        end
    end
end

