function [ok, status, time] = solveMultiPhase(simcase, varargin)
    opt = struct('resetData', false, ...
        'injectionTimeStep' , 10*minute, ...
        'settleTimeStep'    , 10*minute,...
        'dim'               , 3, ...
        'usedeck'           , true, ...
        'Jutul'             , false, ...
        'direct_solver'     , false);
    status = struct();

    [opt, extra] = merge_options(opt, varargin{:});
    dirName       = fullfile(simcase.dataOutputDir, simcase.casename);

    [state0, model, schedule, nls] = setupSim(simcase, 'direct_solver', opt.direct_solver, extra{:});
    % assert(all(state0.s(:,2)==0))
    % assert(all(state0.s(:,1)==1))

    problem = packSimulationProblem(state0, model, ...
        schedule, simcase.casename, ...
                    'Directory', dirName, ... %getdirname(dirname)
                    'NonLinearSolver', nls, ...
                    'Name'           , 'multiphase');
    
    restartStep = nan;
    checkTooMany = true;
    if opt.resetData
        restartStep = 1;
        checkTooMany = false;
    end
    tic();
    if opt.Jutul
        if opt.resetData
            restartStep = 1;
        else
            restartStep = true;
        end
        projPath = '~/Code/prosjekt-master/jutul';
        outputfolder = fullfile(simcase.dataOutputDir);
        [~, ~] = simulatePackedProblemJutul(problem, 'name', simcase.casename, 'project', projPath, 'path', outputfolder, ...
            'restart', restartStep);
            % 'output_path', fullfile('/media/kristian/HDD/Jutul/output/',simcase.casename)
        ok = true;%?
    else
        [ok, status] = simulatePackedProblem(problem, ...
                                  'restartStep', restartStep, ...
                                  'checkTooMany', checkTooMany, ...
                                  'continueOnError', true);
    end
    time = toc();
end
