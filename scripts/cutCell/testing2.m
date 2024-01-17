clear all 
close all
%%
gridcase = 'cut1080x463';
simcase = Simcase('gridcase', gridcase);
G = simcase.G;
plotToolbar(G, G.cells.tag);
% ortherr = simcase.computeStaticIndicator;
% plotToolbar(simcase.G, ortherr);view(0,0);
% colorbar
%% Fra August
N = [20 20 10]/5;
L = [20 20 5];
G = addBoundingBoxFields(computeGeometry(cartGrid(N, L)));
x = linspace(-1, 21, 20)';
points = [x, 10+5*cos(.2*x), .2*x];
%points = [x,x,x];
cutDir = [0 0 1];
[G, ix1, g21] = sliceGrid(G, points, 'cutDir', cutDir);
plotFaces(G, ix1.new.faces==3, 'FaceColor', 'm', 'FaceAlpha', 1, 'EdgeAlpha', .2);
m = markCutGrids(G, ix1.new.faces);
plotCellData(G, m)

%%
points = [0 0 0; 1 1 0; 0.5, 1.5 0; 1 2 0]/10;
dir = [0 0 1];
[Gs, ix, g] = sliceGrid(G, points, 'cutDir', dir);
m = markCutGrids(Gs, ix.new.faces);
% plotGrid(Gs, 'facealpha', 0.1);
plotCellData(Gs, m, 'facealpha', 0.2);
axis equal;
%% Aggregate points for a loop
pointsinds = cell2mat(geodata.Line(abs(geodata.Loop{7})));
pointsinds = unique(pointsinds(:), "stable");
points = geodata.Point(pointsinds);
points =cell2mat(points(:));

%%
G = cartGrid([1 1 1], [10 10 1]);
G = computeGeometry(G);
% G.nodes.coords(:,3) = 0;
% G = repairNormals(computeGeometry(G));
% G = repairNormals(G);
plotGrid(G);
pnts = [-1 0 0;5 8 0;11 4 0];
cutDir = [0 0 1];
Gslice = sliceGrid(G, pnts, 'cutDir', cutDir);
plotGrid(Gslice);
%%
plot(0,0);hold on;
Gslice = G;
dir = [0 0 1];
for ipoint = 1:numel(pnts)
    
    point = pnts(ipoint,:);
    plot(point(1), point(2), 'ro');
    cell = findEnclosingCell(Gslice, point);
    if cell == 0 
        if ipoint ~= numel(pnts)
            break
        else
            continue
        end
    end
    faceCentroids = Gslice.faces.centroids(Gslice.cells.faces(Gslice.cells.facePos(cell):Gslice.cells.facePos(cell+1)-1), :);
    faceymax = max(faceCentroids(:, 2));
    faceymin = min(faceCentroids(:, 2));
    facexmax = max(faceCentroids(:, 1));
    facexmin = min(faceCentroids(:, 1));

    ydist = min(faceymax - point(2), point(2)-faceymin);
    xdist = min(facexmax - point(1), point(1)-facexmin);
    [dist, splitdir] = min([xdist, ydist]);
    if dist ~= 0
        %Split cell
        if splitdir == 1
            splitpoints = [facexmin point(2) 0; 
                           facexmax point(2) 0];
        elseif splitdir == 2
            splitpoints = [point(1) faceymin 0; 
                           point(1) faceymax 0];
        end
        Gslice = sliceGrid(Gslice, splitpoints, 'cutDir', dir);
        % Gslice = repairNormals(computeGeometry(G));
        Gslice = repairNormals(Gslice);
        plotGrid(Gslice, 'facealpha', 0.1, 'edgealpha', 0.2);
    end
end

%% Main cutting

dir = [0 0 1];
G = cartGrid([4 4], [2.8 1.2]);
G.nodes.coords(:,3) = 0;
G = repairNormals(computeGeometry(G));
G = repairNormals(G);

% p = [0 0 0; 1 1 0; 2.8 1.2 0];
% Gcut = sliceGrid(G, p, 'cutDir', dir);
% plotGrid(Gcut);
%% Main cutting
G = computeGeometry(G);
% G = repairNormals(G);
Gcut = G;
for ifacies = 1:7
    loops = geodata.Facies{ifacies};
    numLoops = numel(loops);
    for iLoop = 1:numLoops
        loop = loops(iLoop);
        pointsinds = cell2mat(geodata.Line(abs(geodata.Loop{loop})));
        pointsinds = unique(pointsinds(:), "stable");
        % pointsinds(end+1) = pointsinds(1);
        points = geodata.Point(pointsinds);
        points = cell2mat(points(:));
        plot(0,0);
        axis([0 2.8 0 1.2]);
        axis equal;
        hold on
        xpts = points(:,1 );
        ypts = points(:,2 );
        plot(xpts, ypts, '-ro');

        [Gcut, ix] = sliceGrid(Gcut, points, 'cutDir', dir);
        % Gcut = repairNormals(Gcut, 'facealpha', 0);
        % plotGrid(Gcut);axis equal tight;
    end
end

%% Pre split cells, so nodes are never inside cells
% plot(0,0);
% hold on;
% plot(2.8, 1.2);
% Gcut = G;
% dir = [0 0 1];
disp("Presplitting grid the new way...")
tic();
eps = 1e-10;
numpoints = numel(geodata.Point);
Gcut = G;
dir = [0 0 1];
splits = {};
for ipoint = 1:numpoints
    
    point = geodata.Point{ipoint};
    % plot(point(1), point(2), 'ro');
    c = findEnclosingCell(Gcut, point);
    if c == 0
        if ipoint == numpoints
            break
        else
            continue
        end
    end
    faceCentroids = Gcut.faces.centroids(Gcut.cells.faces(Gcut.cells.facePos(c):Gcut.cells.facePos(c+1)-1), :);
    faceymax = max(faceCentroids(:, 2));
    faceymin = min(faceCentroids(:, 2));
    facexmax = max(faceCentroids(:, 1));
    facexmin = min(faceCentroids(:, 1));

    ydist = min(faceymax - point(2), point(2)-faceymin);
    xdist = min(facexmax - point(1), point(1)-facexmin);
    [dist, splitdir] = min([xdist, ydist]);
    if dist ~= 0
        %Split cell
        if splitdir == 1
            splitpoints = [facexmin-eps point(2) 0; 
                           facexmax+eps point(2) 0];
        elseif splitdir == 2
            splitpoints = [point(1) faceymin-eps 0; 
                           point(1) faceymax+eps 0];
        end
        splits{end+1} = splitpoints;
        % Gcut = sliceGrid(Gcut, splitpoints, 'cutDir', dir);
        % Gcut = repairNormals(computeGeometry(Gcut));
        % Gcut = repairNormals(Gcut);
        % plotGrid(Gcut, 'facealpha', 0, 'edgealpha', 0.2);
    end
end
dd = repmat({dir}, 1, numel(splits));
Gcut = sliceGrid(Gcut, splits, 'cutDir', dd);
t = toc();
sprintf("Done in %0.2f s", t)

%% Main Cut based on individual lines

dir = [0 0 1];
disp("Main splitting...");
tic();
% Gcut = computeGeometry(Gcut);
% Gcut = repairNormals(Gcut);
Gcut = Gpresplit;
numlines = numel(geodata.Line);
f = waitbar(0, 'Starting');
for iline = 1:numlines
    % dispif(iline >= 1, '%d\n', iline);
    waitbar(iline/numlines, f, sprintf('Splitting progress: %d %%. (%d/%d).', floor(iline/numlines*100), iline, numlines))
    if ismember(iline, geodata.BoundaryLines)%skip boundarylines
        continue
    end
    line = geodata.Line{iline};
    points = geodata.Point(line);
    points = cell2mat(points(:));

    % xpts = points(:,1 );
    % ypts = points(:,2 );
    % plot(xpts, ypts, 'ro');
    % hold off;

    try
        [Gcut, ix] = sliceGrid(Gcut, points, 'cutDir', dir);
        % Gcut = repairNormals(Gcut);
        % plotGrid(Gcut, 'facealpha', 0);axis equal tight;
        % axis([0 2.8 0 1.2]);
        % hold on;
    catch
        sprintf("failed for line %d", iline);
    end
end
close(f);
t = toc();
fprintf("Done in %0.2f s\n", t);

%% New Main Cut based on individual lines

dir = [0 0 1];
disp("New Main splitting...");
tic();
numlines = numel(geodata.Line);
Gcut = Gpresplit;
pp = {};
for iline = 1:numlines
    if ismember(iline, geodata.BoundaryLines)%skip boundarylines
        continue
    end
    line = geodata.Line{iline};
    points = geodata.Point(line);
    points = cell2mat(points(:));

    % xpts = points(:,1 );
    % ypts = points(:,2 );
    % plot(xpts, ypts, 'ro');
    % hold off;

    pp{end+1} = points;
end
dd = repmat({dir}, 1, numel(pp));
Gcut = sliceGrid(Gcut, pp, 'cutDir', dd);
t = toc();
fprintf("Done in %0.2f s\n", t);
%% Plot loops
% plot(0,0);
% axis([0 2.8 0 1.2]);
% axis equal;
% plotGrid(Gcut, 'facealpha', 0);axis tight;


data = geodata;
% data = geodata;
for ifacies = 1:7
    loops = data.Facies{ifacies};
    numLoops = numel(loops);
    for iLoop = 1:numLoops
        loop = loops(iLoop);
        pointsinds = cell2mat(data.Line(abs(data.Loop{loop})));
        pointsinds = unique(pointsinds(:), "stable");
        pointsinds(end+1) = pointsinds(1);
        points = data.Point(pointsinds);
        points = cell2mat(points(:));
        xpts = points(:,1 );
        ypts = points(:,2 );
        plot(xpts, ypts, '-o');
        axis([-0.1 2.9 -0.1 1.3]);
        axis equal;
        ax = gca;
        ax.TickLength = [0,0];
        hold on
        disp(loop)
    end
end
%% Stats for main splitter
stats = cell2mat(sliceStats(:));
plot(stats(:,1), stats(:,2))
timepercell = stats(end, 2)/stats(end, 1);%~0.004 s per cell
%over two hours for two million cells
%% Stats for presplitter
stats = cell2mat(presplitstats(:));
plot(stats(:,1), stats(:,2))
timepercell = stats(end, 2)/stats(end, 1);%~0.004 s per cell
%over two hours for two million cells
%% Rename variables in stored grids from Gcut to G
% Specify the directory where your .mat files are located
directoryPath = 'grid-files\cutcell';

% Get a list of all .mat files in the directory
matFiles = dir(fullfile(directoryPath, '*.mat'));

% Loop through each .mat file
for i = 1:numel(matFiles)
    matFileName = matFiles(i).name;
    fullPath = fullfile(directoryPath, matFileName);
    
    % Load the .mat file
    load(fullPath, 'Gcut');
    
    % Rename the variable to 'G'
    G = Gcut;
    
    % Save it back to the same file
    save(fullPath, 'G');
    
    % Clear the variables from the workspace
    clear('G', 'Gcut');
end
