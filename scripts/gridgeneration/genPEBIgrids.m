% Test different nx, nz combinations for ~25k cells
nx_values = 420:20:440;  % Range around 420
nz_values = 50:5:70;     % Range around 60

results = struct('nx', {}, 'nz', {}, 'success', {});
idx = 1;

fprintf('Testing grid generation with different nx, nz combinations:\n');
fprintf('%-6s %-6s %-10s\n', 'nx', 'nz', 'status');
fprintf('--------------------------------\n');

for nx = nx_values
    for nz = nz_values
        try
            generatePEBIGrid(nx, nz, 'SPEcase', 'B', 'save', false, 'earlyReturn', true, 'aspect', 'square');
            success = true;
        catch ME
            success = false;
        end
        
        % Store results
        results(idx).nx = nx;
        results(idx).nz = nz;
        results(idx).success = success;
        
        % Print result
        if success
            status = 'OK';
        else
            status = 'FAILED';
        end
        fprintf('%-6d %-6d %-10s\n', nx, nz, status);
        
        idx = idx + 1;
    end
end

% Print summary of successful combinations
fprintf('\nSuccessful combinations:\n');
fprintf('%-6s %-6s\n', 'nx', 'nz');
fprintf('-------------\n');

successful = [results.success];
good_results = find(successful);

for i = good_results
    fprintf('%-6d %-6d\n', results(i).nx, results(i).nz);
end
%%
G = generatePEBIGrid(420, 60, 'SPEcase', 'B', 'save', true, 'aspect', 'square');

%%
% Define custom colors for tags 1-7
customColors = [
    200,150,39;  
    124,149,189;    
    200,134,103;  
    190,81,62;  
    70,122,33;  
    110,33,172;  
    167,166,163  
]/255;

% Create plot
close all;
figure
plotCellData(G,G.cells.tag);
view(0,0);

% Customize the plot
ax = gca;
set(ax, 'Color', [167,166,163]/255); % Set background color to light gray
set(ax, 'xlim', [1050, 1650], 'zlim', [440, 1050]);

% Apply custom colormap for the integer tags
colormap(customColors);
caxis([1 7]); % Set color axis limits to match our tag range
% savepath = ['./plots/RSC/grids-fault/', gridcase_to_RSCname(gridcase), '_fault.png']
% exportgraphics(gcf, savepath, 'ContentType','Auto', Resolution=500);
