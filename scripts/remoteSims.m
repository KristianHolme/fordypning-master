function timings = remoteSims(server)
    mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
        ad-blackoil postprocessing diagnostics prosjektOppgave...
        deckformat gmsh nfvm mpfa
    % gridcases = {'tetRef10', 'tetRef8', 'tetRef6', 'tetRef4', 'tetRef2'};
    % schedulecases = {'simple-coarse', 'simple-std'};
    mrstVerbose off
    switch  server
        case 1
            gridcases = {'5tetRef2'};
            schedulecases = {''};
            discmethods = {'', 'hybrid-ntpfa'};
            deckcases = {'RS'};
            tagcase = '';
            resetData = false;
            do.multiphase = true;
            Jutul = false;
            direct_solver = false;
            griddim = 2;
        case 2
            gridcases = {'5tetRef2'};
            schedulecases = {''};
            discmethods = {'hybrid-avgmpfa', 'hybrid-mpfa'};
            deckcases = {'RS'};
            tagcase = '';
            resetData = false;
            do.multiphase = true;
            Jutul = false;
            direct_solver = false;
            griddim = 2;
        case 3
            gridcases = {'5tetRef2'};
            schedulecases = {''};
            discmethods = {'', 'hybrid-ntpfa'};
            deckcases = {'RS'};
            tagcase = '';
            resetData = false;
            do.multiphase = true;
            Jutul = false;
            direct_solver = false;
            griddim = 3;
        case 4
            gridcases = {'5tetRef2'};
            schedulecases = {''};
            discmethods = {'hybrid-avgmpfa', 'hybrid-mpfa'};
            deckcases = {'RS'};
            tagcase = '';
            resetData = false;
            do.multiphase = true;
            Jutul = false;
            direct_solver = false;
            griddim = 3;
    end
    
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
                                    'discmethod', discmethod, 'griddim', griddim);
                    if do.multiphase
                        [ok, status, time] = solveMultiPhase(simcase, 'resetData', resetData, 'Jutul', Jutul, ...
                                            'direct_solver', direct_solver);
                        disp(['Done with: ', simcase.casename]);
                        timings.(timingName(simcase.casename)) = time;
                    end
                end
            end
        end
    end
    disp(timings);