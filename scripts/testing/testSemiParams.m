clear all
close all
%%
addpath("Nevland\FluidFlower\");
%% Load
load("Misc\goodparams.mat");

checkedgoodparams = [];
h = waitbar(0, 'Checking grids...'); % Initialize waitbar
count = 0;
numgoodparams = size(goodparams, 1);
for i = 1:numgoodparams
    params = goodparams(i,:);
    nx = params(1);nz = params(2); density = params(3);
    G = genHybridGrid('nx', nx, 'nz', nz, 'density', density);
    [output, ok] = evalc('checkGrid(G)');
    if ok
        checkedgoodparams(end+1, :) = params;
    end
    count = count +1;
    waitbar(count / numgoodparams, h, sprintf('Processing %d/%d', count, numgoodparams));
end
return
%% Testing which params work with semistruct-grid

printbad = false;
printgood = true;

nxs = 20:340;
nzs = 20:200;
densities = [0.3, 0.5];

% nxs = 20:22;
% nzs = 20:22;
% densities = [0.5];

goodparams = [];
badparams = [];

total_iterations = numel(nxs) * numel(nzs) * numel(densities);
count = 0;

h = waitbar(0, 'Processing...');  % Initialize waitbar

for nx = nxs
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
return
%% Load
load("Misc\goodparams.mat");



