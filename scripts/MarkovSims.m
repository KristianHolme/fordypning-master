function timings = MarkovSims(server)
    mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
        ad-blackoil postprocessing diagnostics prosjektOppgave...
        deckformat gmsh nfvm mpfa coarsegrid
    % gridcases = {'tetRef10', 'tetRef8', 'tetRef6', 'tetRef4', 'tetRef2'};
    % schedulecases = {'simple-coarse', 'simple-std'};
    mrstVerbose off
    switch  server
        case 1
            SPEcase = 'C';
            gridcases = {'struct100x100x100'};
            schedulecases = {''};
            pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'cc', 'hybrid-mpfa'};
            uwdiscs = {''};
            deckcases = {'B_ISO_C'};
            tagcase = '';
            resetData = true;
            resetAssembly = true;
            do.multiphase = true;
            Jutul = false;
            direct_solver = false;
        case 2
            SPEcase = 'C';
            gridcases = {'struct50x50x50'};
            schedulecases = {''};
            pdiscs = {'hybrid-mpfa'};
            uwdiscs = {''};
            deckcases = {'B_ISO_C'};
            tagcase = '';
            resetData = true;
            resetAssembly = true;
            do.multiphase = true;
            Jutul = false;
            direct_solver = false;
        case 3
             SPEcase = 'C';
            gridcases = {'horz_pre_cut_PG_50x50x50'};
            schedulecases = {''};
            pdiscs = {'', 'hybrid-avgmpfa'};
            uwdiscs = {''};
            deckcases = {'B_ISO_C'};
            tagcase = '';
            resetData = true;
            resetAssembly = true;
            do.multiphase = true;
            Jutul = false;
            direct_solver = false;
        case 4
             SPEcase = 'C';
            gridcases = {'horz_pre_cut_PG_50x50x50'};
            schedulecases = {''};
            pdiscs = {'hybrid-ntpfa', 'cc'};
            uwdiscs = {''};
            deckcases = {'B_ISO_C'};
            tagcase = '';
            resetData = true;
            resetAssembly = true;
            do.multiphase = true;
            Jutul = false;
            direct_solver = false;
    end
    
    warning('off', 'all');
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

    warning('on', 'all');
    disp(timings);
