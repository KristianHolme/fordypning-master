function timings = MarkovSims(server)
    mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
        ad-blackoil postprocessing diagnostics prosjektOppgave...
        deckformat gmsh nfvm mpfa coarsegrid
    % gridcases = {'tetRef10', 'tetRef8', 'tetRef6', 'tetRef4', 'tetRef2'};
    % schedulecases = {'simple-coarse', 'simple-std'};
    mrstVerbose off
    switch  server
        case 1
            SPEcase = 'B';
            gridcases = {'struct220x110'};
            schedulecases = {''};
            pdiscs = {''};
            uwdiscs = {''};
            deckcases = {'B_ISO_C'};
            tagcase = 'test';
            resetData = true;
            resetAssembly = true;
            do.multiphase = true;
            Jutul = false;
            direct_solver = false;
        case 2
            SPEcase = 'B';
            gridcases = {'struct220x110'};
            schedulecases = {''};
            pdiscs = {''};
            uwdiscs = {''};
            deckcases = {'B_ISO_C'};
            tagcase = 'test';
            resetData = true;
            resetAssembly = true;
            do.multiphase = true;
            Jutul = true;
            direct_solver = false;
        case 3
            SPEcase = 'B';
            gridcases = {''};
            schedulecases = {''};
            pdiscs = {''};
            uwdiscs = {''};
            deckcases = {'B_ISO_C'};
            tagcase = '';
            resetData = true;
            resetAssembly = true;
            do.multiphase = true;
            Jutul = false;
            direct_solver = false;
        case 4
            SPEcase = 'B';
            gridcases = {'cut210x70'};
            schedulecases = {''};
            pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
            uwdiscs = {''};
            deckcases = {'RS'};
            tagcase = '';
            resetData = false;
            resetAssembly = true;
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
                for ipdisc = 1:numel(pdiscs)
                    pdisc = pdiscs{ipdisc};
                    for iuwdisc = 1:numel(uwdiscs)
                        uwdisc = uwdiscs{iuwdisc};
                        simcase = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                                        'schedulecase', schedulecase, 'tagcase', tagcase, ...
                                        'pdisc', pdisc, 'uwdisc', uwdisc);
                        if do.multiphase
                            [ok, status, time] = solveMultiPhase(simcase, 'resetData', resetData, 'Jutul', Jutul, ...
                                                'direct_solver', direct_solver, 'resetAssembly', resetAssembly);
                            disp(['Done with: ', simcase.casename]);
                            timings.(timingName(simcase.casename)) = time;
                        end
                    end
                end
            end
        end
    end
    disp(timings);
