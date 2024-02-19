function timings = runSims2(server)
    mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh nfvm mpfa coarsegrid
    % gridcases = {'tetRef10', 'tetRef8', 'tetRef6', 'tetRef4', 'tetRef2'};
    % schedulecases = {'simple-coarse', 'simple-std'};
    mrstVerbose off
    switch  server
    case 1
        SPEcase = 'B';
<<<<<<< Updated upstream
        gridcases = {'horz_ndg_cut_PG_898x120', 'horz_pre_cut_PG_898x120'};
=======
        gridcases = {'horz_ndg_cut_PG_460x64', 'horz_pre_cut_PG_460x64'};
>>>>>>> Stashed changes
        schedulecases = {''};
        pdiscs = {'', 'cc', 'hybrid-ntpfa', 'hybrid-avgmpfa'};
        uwdiscs = {''};
        deckcases = {'B_ISO_SMALL'};
        tagcase = '';
        resetData = false;
        resetAssembly = true;
        Jutul = false;
        direct_solver = false;
    case 2
        SPEcase = 'B';
<<<<<<< Updated upstream
        gridcases = {'cart_ndg_cut_PG_898x120', 'cart_pre_cut_PG_898x120'};
=======
        gridcases = {'cart_ndg_cut_PG_460x64', 'cart_pre_cut_PG_460x64'};
>>>>>>> Stashed changes
        schedulecases = {''};
        pdiscs = {'', 'cc', 'hybrid-ntpfa', 'hybrid-avgmpfa'};
        uwdiscs = {''};
        deckcases = {'B_ISO_SMALL'};
        tagcase = '';
        resetData = false;
        resetAssembly = true;
        Jutul = false;
        direct_solver = false;
    case 3
        SPEcase = 'B';
        gridcases = {'struct130x62'};
        schedulecases = {''};
        pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa'};
        uwdiscs = {''};
        deckcases = {'B_ISO_SMALL'};
        tagcase = '';
        resetData = true;
        resetAssembly = true;
        Jutul = false;
        direct_solver = false;
        mrstVerbose off;
    case 4
        SPEcase = 'B';
        gridcases = {''};
        schedulecases = {''};
        pdiscs = {'hybrid-avgmpfa', 'hybrid-ntpfa'};
        uwdiscs = {''};
        deckcases = {'B_ISO_SMALL'};
        tagcase = 'normalRock';
        resetData = true;
        resetAssembly = true;
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
end
