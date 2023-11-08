function timings = runSims2(server)
    mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
        ad-blackoil postprocessing diagnostics prosjektOppgave...
        deckformat gmsh nfvm mpfa
    % gridcases = {'tetRef10', 'tetRef8', 'tetRef6', 'tetRef4', 'tetRef2'};
    % schedulecases = {'simple-coarse', 'simple-std'};
    mrstVerbose off
    switch  server
        case 1
            gridcases = {'struct193x83'};
            schedulecases = {''};
            pdiscs = {''};
            uwdiscs = {'WENO'};
            deckcases = {'RS'};
            tagcase = '';
            resetData = false;
            resetAssembly = true;
            Jutul = false;
            direct_solver = false;
        case 2
            gridcases = {'semi203x72_0.3'};
            schedulecases = {''};
            pdiscs = {''};
            uwdiscs = {'WENO'};
            deckcases = {'RS'};
            tagcase = '';
            resetData = false;
            resetAssembly = true;
            Jutul = false;
            direct_solver = false;
        case 3
            gridcases = {'5tetRef2-2D'};
            schedulecases = {''};
            pdiscs = {'hybrid-ntpfa'};
            uwdiscs = {'', 'WENO'};
            deckcases = {'RS'};
            tagcase = '';
            resetData = false;
            resetAssembly = true;
            Jutul = false;
            direct_solver = false;
        case 4
            gridcases = {'5tetRef1'};
            schedulecases = {''};
            pdiscs = {''};
            uwdiscs = {''};
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
                        simcase = Simcase('deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
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