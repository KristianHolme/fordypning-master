function timings = runSims2(server)
    mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh nfvm mpfa coarsegrid jutul
    % gridcases = {'tetRef10', 'tetRef8', 'tetRef6', 'tetRef4', 'tetRef2'};
    % schedulecases = {'simple-coarse', 'simple-std'};
    mrstVerbose off
    switch  server
    case 1
        SPEcase = 'B';
        gridcases = {'', 'struct130x62', 'horz_ndg_cut_PG_130x62', 'cart_ndg_cut_PG_130x62', 'cPEBI_130x62'};
        schedulecases = {''};
        pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
        uwdiscs = {''};
        deckcases = {'B_ISO_C'};
        tagcase = '';
        resetData = false;
        resetAssembly = false;
        Jutul = false;
        direct_solver = false;
        warning('off', 'all');
    case 2
        SPEcase = 'B';
        gridcases = {'struct220x110', 'horz_ndg_cut_PG_220x110', 'cart_ndg_cut_PG_220x110', 'cPEBI_220x110'};
        schedulecases = {''};
        pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
        uwdiscs = {''};
        deckcases = {'B_ISO_C'};
        tagcase = '';
        resetData = false;
        resetAssembly = false;
        Jutul = false;
        direct_solver = false;
        warning('off', 'all');
    case 3
        SPEcase = 'B';
        gridcases = {'struct819x117', 'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117', '5tetRef0.31'};
        schedulecases = {''};
        pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
        uwdiscs = {''};
        deckcases = {'B_ISO_C'};
        tagcase = '';
        resetData = false;
        resetAssembly = false;
        Jutul = false;
        direct_solver = false;
        warning('off', 'all');
    case 4
        SPEcase = 'B';
        gridcases = {'5tetRef0.31'};
        schedulecases = {''};
        pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
        uwdiscs = {''};
        deckcases = {'B_ISO_C'};
        tagcase = '';
        resetData = false;
        resetAssembly = false;
        Jutul = false;
        direct_solver = false;
        warning('off', 'all');
    end
    if Jutul, mrstVerbose on,else, mrstVerbose off,end

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
                            'pdisc', pdisc, 'uwdisc', uwdisc, 'jutul', Jutul);

                        [~, ~, time] = solveMultiPhase(simcase, 'resetData', resetData, 'Jutul', Jutul, ...
                            'direct_solver', direct_solver, 'resetAssembly', resetAssembly);
                        disp(['Done with: ', simcase.casename]);
                        timings.(timingName(simcase.casename)) = time;

                    end
                end
            end
        end
    end
    disp(timings);
    warning('on', 'all');
end
