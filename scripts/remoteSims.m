function timings = remoteSims(server)
    mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
        ad-blackoil postprocessing diagnostics prosjektOppgave...
        deckformat gmsh nfvm mpfa
    % gridcases = {'tetRef10', 'tetRef8', 'tetRef6', 'tetRef4', 'tetRef2'};
    % schedulecases = {'simple-coarse', 'simple-std'};
    
    switch  server
        case 1
            gridcases = {'5tetRef10', '5tetRef6', '5tetRef4', '5tetRef2'};
            schedulecases = {''};
            discmethods = {'', 'hybrid-avgmpfa-oo', 'hybrid-mpfa-oo', 'hybrid-ntpfa-oo'};
            deckcases = {'RS'};
            tagcase = '';
            resetData = false;
            do.multiphase = true;
            Jutul = false;
            direct_solver = false;
        case 2
            gridcases = {'struct340x150', 'struct220x90'};
            schedulecases = {''};
            discmethods = {'', 'hybrid-avgmpfa-oo', 'hybrid-ntpfa-oo'};
            deckcases = {'RS'};
            tagcase = '';
            resetData = false;
            do.multiphase = true;
            Jutul = false;
            direct_solver = false;
        case 3
            gridcases = {'semi188x38_0.3', 'semi263x154_0.3'};
            schedulecases = {''};
            discmethods = {'', 'hybrid-avgmpfa-oo', 'hybrid-ntpfa-oo'};
            deckcases = {'RS'};
            tagcase = '';
            resetData = false;
            do.multiphase = true;
            Jutul = false;
            direct_solver = false;
        case 4
            gridcases = {'5tetRef1'};
            schedulecases = {''};
            discmethods = {'', 'hybrid-avgmpfa-oo', 'hybrid-mpfa-oo'};
            deckcases = {'RS'};
            tagcase = '';
            resetData = false;
            do.multiphase = true;
            Jutul = false;
            direct_solver = false;
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
                                    'discmethod', discmethod);
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