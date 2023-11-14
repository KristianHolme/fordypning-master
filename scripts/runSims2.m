function timings = runSims2(server)
    mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
        ad-blackoil postprocessing diagnostics prosjektOppgave...
        deckformat gmsh nfvm mpfa
    % gridcases = {'tetRef10', 'tetRef8', 'tetRef6', 'tetRef4', 'tetRef2'};
    % schedulecases = {'simple-coarse', 'simple-std'};
    mrstVerbose off
    switch  server
        case 1
            SPEcase = 'B';
            gridcases = {''};
            schedulecases = {''};
            pdiscs = {''};
            uwdiscs = {''};
            deckcases = {'RS'};
            tagcase = '';
            resetData = false;
            resetAssembly = true;
            Jutul = false;
            direct_solver = false;
        case 2
            SPEcase = 'B';
            gridcases = {'5tetRef10'};
            schedulecases = {''};
            pdiscs = {'hybrid-ntpfa'};
            uwdiscs = {''};
            deckcases = {'RS'};
            tagcase = '';
            resetData = false;
            resetAssembly = true;
            Jutul = false;
            direct_solver = false;
        case 3
            SPEcase = 'B';
            gridcases = {'5tetRef3'};
            schedulecases = {''};
            pdiscs = {'hybrid-avgmpfa'};
            uwdiscs = {'WENO'};
            deckcases = {'RS'};
            tagcase = '';
            resetData = false;
            resetAssembly = true;
            Jutul = false;
            direct_solver = false;
            mrstVerbose on;
        case 4
            SPEcase = 'B';
            gridcases = {''};
            schedulecases = {''};
            pdiscs = {''};
            uwdiscs = {'WENO'};
            deckcases = {'RS'};
            tagcase = '';
            resetData = false;
            resetAssembly = false;
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
                for idisc = 1:numel(pdiscs)
                    pdisc = pdiscs{idisc};
                    for iuwdisc = 1:numel(uwdiscs)
                        uwdisc = uwdiscs{iuwdisc};
                        simcase = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                                        'schedulecase', schedulecase, 'tagcase', tagcase, ...
                                        'pdisc', pdisc, 'uwdisc', uwdisc);

                        [ok, status, time] = solveMultiPhase(simcase, 'resetData', resetData, 'Jutul', Jutul, ...
                                            'direct_solver', direct_solver, 'resetAssembly', resetAssembly);
                        disp(['Done with: ', simcase.casename]);
                        timings.(timingName(simcase.casename)) = time;

                    end
                end
            end
        end
    end
    disp(timings);