%used for running simulations from terminal
function timings = runSims2(server)
    % gridcases = {'tetRef10', 'tetRef8', 'tetRef6', 'tetRef4', 'tetRef2'};
    % schedulecases = {'simple-coarse', 'simple-std'};
    mrstVerbose off
    switch  server
    case 1
        SPEcase = 'B';
        gridcases = getRSCGridcases({'HC', 'CC'}, [10, 50]);
        schedulecases = {''};
        pdiscs = {'', 'hybrid-ntpfa', 'hybrid-avgmpfa'};
        uwdiscs = {''};
        deckcases = {'B_ISO_C'};
        tagcase = '';
        resetData = false;
        resetAssembly = false;
        Jutul = false;
        direct_solver = false;
        mrstVerbose off;
    case 2
        SPEcase = 'B';
        gridcases = getRSCGridcases({'C'}, [10, 50, 100, 200]);
        schedulecases = {''};
        pdiscs = {''};
        uwdiscs = {''};
        deckcases = {'B_ISO_C'};
        tagcase = '';
        resetData = false;
        resetAssembly = true;
        Jutul = false;
        direct_solver = false;
        mrstVerbose off;
    case 3
        SPEcase = 'B';
        gridcases = getRSCGridcases({'QT', 'T'}, [10, 50]);
        schedulecases = {''};
        pdiscs = {'', 'hybrid-ntpfa', 'hybrid-avgmpfa', 'hybrid-mpfa'};
        uwdiscs = {''};
        deckcases = {'B_ISO_C'};
        tagcase = '';
        resetData = false;
        resetAssembly = false;
        Jutul = false;
        direct_solver = false;
        mrstVerbose off;
    case 4
        SPEcase = 'B';
        gridcases = getRSCGridcases({'QT', 'T'}, [100]);
        schedulecases = {''};
        pdiscs = {'', 'hybrid-ntpfa', 'hybrid-avgmpfa', 'hybrid-mpfa'};
        uwdiscs = {''};
        deckcases = {'B_ISO_C'};
        tagcase = '';
        resetData = false;
        resetAssembly = false;
        Jutul = false;
        direct_solver = false;
        mrstVerbose off;
    case 5
        SPEcase = 'B';
        gridcases = getRSCGridcases({'HC', 'CC', 'PEBI'}, [100]);
        schedulecases = {''};
        pdiscs = {'', 'hybrid-ntpfa', 'hybrid-avgmpfa'};
        uwdiscs = {''};
        deckcases = {'B_ISO_C'};
        tagcase = '';
        resetData = false;
        resetAssembly = false;
        Jutul = false;
        direct_solver = false;
        mrstVerbose off;
    end
    if Jutul, mrstVerbose on,end
    warning('off', 'all');
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

                        [~, ~, time] = runSimulation(simcase, 'resetData', resetData, 'Jutul', Jutul, ...
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
