clear all
close all

%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh nfvm mpfa msrsb coarsegrid jutul
mrstVerbose on
%%
% deckcases = {'RS', 'IMMISCIBLE', 'RS_3PH','RSRV', 'pyopm-Finer', 'pyopm-Coarser'};


%%
% gridcases = {'5tetRef10', '5tetRef8', '5tetRef6', '5tetRef4', '5tetRef2',, 'struct193x83', 'struct220x90', 'struct340x150',
% 'semi188x38_0.3','semi203x72_0.3',  'semi263x154_0.3'};
% schedulecases = {'simple-coarse', 'simple-std'};

SPEcase = 'B';
% gridcases = {'cp_pre_cut_130x62', 'pre_cut_130x62', '5tetRef3-stretch', 'struct130x62', ''};%pre_cut_130x62, 5tetRef1.2
% gridcases = {'', 'struct130x62', 'horz_pre_cut_PG_130x62', 'cart_pre_cut_PG_130x62', 'cPEBI_130x62'};
% gridcases = {'horz_ndg_cut_PG_220x110', 'cart_ndg_cut_PG_220x110', 'cPEBI_220x110'};
% gridcases = {'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117'};
% gridcases = {'horz_ndg_cut_PG_130x62', 'horz_ndg_cut_PG_220x110', 'horz_ndg_cut_PG_819x117'};
% gridcases = {'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117', '5tetRef0.3'};
gridcases = {''};
% pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-ntpfa'};
pdiscs = {''};

schedulecases = {''};%defaults to schedule from deck
deckcases = {'B_ISO_C'}; %B_ISO_C
uwdiscs = {''};
disc_prio = 1;%1 means tpfa prio when creating faceblocks for hybrid discretization, 2 means prio other method
tagcase = '';%normalRock, bufferMult, deckrock
Jutul               = true;

resetData           = true;
resetAssembly       = true;
do.plotStates       = true;
do.plotFlux         = false;
do.multiphase       = true;
do.plotOrthErr      = false;
do.dispTime         = false;
direct_solver       = false; %may not be respected if backslashThreshold is not met
mrstVerbose on;

Totvols = {};
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
                                    'pdisc', pdisc, 'uwdisc', uwdisc, 'jutul', Jutul);
                    if do.multiphase
                        [ok, status, time] = solveMultiPhase(simcase, 'resetData', resetData, 'Jutul', Jutul, ...
                                            'direct_solver', direct_solver, 'prio', disc_prio, 'resetAssembly', resetAssembly);
                        disp(['Done with: ', simcase.casename]);
                        timingname = replace(simcase.casename, '=', '_');
                        timingname = replace(timingname, '-', '_');
                        timingname = replace(timingname, '.', '_');
                        timings.(timingname) = time;
                    end
                    if do.dispTime
                        fprintf('Timing: %s: %0.2f\n', simcase.casename, simcase.getWallTime);
                    end
                    if do.plotStates
                        simcase.plotStates('lockCaxis', false);
                        % clim([0 6e-7]);
                    end
                    if do.plotFlux
                        simcase.plotFlux();
                    end
                    if do.plotOrthErr
                        simcase.plotErr('plotHistogram', true, 'resetData', true);
                    end
                    % Totvols{end+1,1} =  simcase.gridcase;
                    % Totvols{end,2} =  sum(simcase.G.cells.volumes(simcase.G.bufferCells) .* simcase.rock.bufferMult);
                end
            end
        end
    end
end
if do.dispTime
    disp(timings);
end
disp(Totvols);
