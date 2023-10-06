mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh
% gridcases = {'tetRef10', 'tetRef8', 'tetRef6', 'tetRef4', 'tetRef2'};
% schedulecases = {'simple-coarse', 'simple-std'};

gridcases = {'tetRef1', 'struct340x150', 'tetRef0.8'};
schedulecases = {'simple-std'};
deckcases = {'RS'};

resetData = false;
do.multiphase = true;


timings = struct();
for ideck = 1:numel(deckcases)
    deckcase = deckcases{ideck};
    for igrid = 1:numel(gridcases)
        gridcase = gridcases{igrid};
        for ischedule = 1:numel(schedulecases)
            schedulecase = schedulecases{ischedule};

            simcase = Simcase('deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                            'schedulecase', schedulecase);
            if do.multiphase
                [ok, status, time] = solveMultiPhase(simcase, 'resetData', resetData);
                timings.(simcase.gridcase) = time;
            end
        end
    end
end
disp(timings);