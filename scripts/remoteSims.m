mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh nfvm
% gridcases = {'tetRef10', 'tetRef8', 'tetRef6', 'tetRef4', 'tetRef2'};
% schedulecases = {'simple-coarse', 'simple-std'};

gridcases = {'tetRef2'};
schedulecases = {''};
discmethods = {'hybrid-mpfa-oo'};
deckcases = {'RS'};
tagcase = '';

resetData = false;
do.multiphase = true;
Jutul = false;
direct_solver = false;

timings = struct();
for ideck = 1:numel(deckcases)
    deckcase = deckcases{ideck};
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
                                        'direct_solver', direct_solver);
                    disp(['Done with: ', simcase.casename]);
                    timingname = replace(simcase.casename, '=', '_');
                    timingname = replace(timingname, '-', '_');
                    timings.(timingname) = time;
                end
            end
        end
    end
end
disp(timings);