clear all
close all

%% Testing which params work with semistruct-grid
version = 'A';

printbad = false;
printgood = true;

targetcellnumber = 50000;
slack = 10000;


nxs = 180:600;
% nzs = 47:240;
densities = [0.3];

% nxs = 20:22;
% nzs = 20:22;
% densities = [0.5];

goodparams = [];
badparams = [];

total_iterations = round(2*slack * sum(1./nxs));
count = 0;

h = waitbar(0, 'Processing...');  % Initialize waitbar
mrstVerbose off;

% Main loop (not parallel)
for nx = nxs
    lower = round((targetcellnumber - slack) / nx);
    upper = round((targetcellnumber + slack) / nx);
    nzs = lower:upper;
    % Parallel loop
    parfor nzIndex = 1:numel(nzs)
        nz = nzs(nzIndex);
        localGood = [];
        localBad = [];

        for id = 1:numel(densities)
            density = densities(id);

            try
                genHybridGrid('nx', nx, 'nz', nz, 'density', density, 'savegrid', false, 'version', version);
                localGood = [localGood; nx, nz, density];
                if printgood
                    fprintf('nx: %d, nz:%d, density: %d succeeded\n', nx, nz, density);
                end
            catch
                localBad = [localBad; nx, nz, density];
                if printbad
                    fprintf('nx: %d, nz:%d, density: %d failed\n', nx, nz, density);
                end
            end
        end

        % Append results from this worker
        goodparams = [goodparams; localGood];
        badparams = [badparams; localBad];
    end

    % Update progress bar (outside the parfor loop)
    count = count + numel(nzs) * numel(densities);
    waitbar(count / total_iterations, h, sprintf('Processing %d/%d', count, total_iterations));
end


% for nx = nxs
%     lower = round((targetcellnumber-slack)/nx);
%     upper = round((targetcellnumber+slack)/nx);
%     parfor nz = nzs
%         for id = 1:numel(densities)
%             density = densities(id);
%             count = count + 1;
%             waitbar(count / total_iterations, h, sprintf('Processing %d/%d', count, total_iterations));
%             try
%                 genHybridGrid('nx', nx, 'nz', nz, 'density', density, 'savegrid', false, 'version', version);
%                 goodparams(end+1,:) = [nx, nz, density];
%                 if printgood
%                     fprintf('nx: %d, nz:%d, density: %d succeeded\n', nx, nz, density);
%                 end
%             catch
%                 if printbad
%                     fprintf('nx: %d, nz:%d, density: %d failed\n', nx, nz, density);
%                 end
%                 badparams(end+1,:) = [nx, nz, density];
%             end
% 
%         end
%     end
% end
close(h);  % Close waitbar
save('Misc/goodparamsA2.mat', 'goodparams');



