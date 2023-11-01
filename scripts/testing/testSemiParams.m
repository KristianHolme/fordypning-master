clear all
close all

%% Testing which params work with semistruct-grid

printbad = false;
printgood = true;

targetcellnumber = 47000;
slack = 5200;


nxs = 260:400;
nzs = 100:220;
densities = [0.3];

% nxs = 20:22;
% nzs = 20:22;
% densities = [0.5];

goodparams = [];
badparams = [];

total_iterations = 4513;
count = 0;

h = waitbar(0, 'Processing...');  % Initialize waitbar

for nx = nxs
    lower = round((target-slack)/nx);
    upper = round((target+slack)/nx);
    for nz = nzs
        for id = 1:numel(densities)
            density = densities(id);
            count = count + 1;
            waitbar(count / total_iterations, h, sprintf('Processing %d/%d', count, total_iterations));
            try
                genHybridGrid('nx', nx, 'nz', nz, 'density', density, 'savegrid', false);
                goodparams(end+1,:) = [nx, nz, density];
                if printgood
                    fprintf('nx: %d, nz:%d, density: %d succeeded\n', nx, nz, density);
                end
            catch
                if printbad
                    fprintf('nx: %d, nz:%d, density: %d failed\n', nx, nz, density);
                end
                badparams(end+1,:) = [nx, nz, density];
            end
            
        end
    end
end
close(h);  % Close waitbar
save('Misc/goodparams2.mat', 'goodparams');



