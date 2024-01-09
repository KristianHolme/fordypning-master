clear all
close all
%% Define Background Grid
Lx = 2.8;
Ly = 1.2;
nx = 1;
ny = 1;
G = cartGrid([nx ny], [Lx, Ly]);
G.nodes.coords(:,3) = 0;
G = repairNormals(computeGeometry(G));
G = repairNormals(G);
plotGrid(G);axis tight equal;
%% Read Geometry
fn = 'C:\Users\holme\Documents\Prosjekt\Prosjektoppgave\src\11thSPE-CSP\geometries\spe11a.geo';
geodata = readGeo(fn);
%assign loops to Fascies
geodata.Facies{1} = [7, 8, 9, 32];
geodata.Facies{7} = [1, 31];
geodata.Facies{5} = [2, 3, 4, 5, 6];
geodata.Facies{4} = [10, 11, 12, 13, 14, 15, 22];
geodata.Facies{3} = [16, 17, 18, 19, 20, 21];
geodata.Facies{6} = [23, 24, 25];
geodata.Facies{2} = [26, 27, 28, 29, 30];
%% Pre split cells, so nodes are never inside cells
Gcut = G;
dir = [0 0 1];
for ipoint = 1:numel(geodata.Point)
    
    point = geodata.Point{ipoint};
    cell = findEnclosingCell(Gcut, point);
    faceCentroids = Gcut.faces.centroids(Gcut.cells.faces(Gcut.cells.facePos(cell):Gcut.cells.facePos(cell+1)-1), :);
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
        Gcut = sliceGrid(Gcut, splitpoints, 'cutDir', dir);
        % Gcut = repairNormals(computeGeometry(G));
        Gcut = repairNormals(Gcut);
        plotGrid(Gcut);
    end
end


%% Main cutting

dir = [0 0 1];
Gcut = computeGeometry(Gcut);
Gcut = repairNormals(Gcut);
for ifacies = 1:7
    loops = geodata.Facies{ifacies};
    numLoops = numel(loops);
    for iLoop = 1:numLoops
        loop = loops(iLoop);
        pointsinds = cell2mat(geodata.Line(abs(geodata.Loop{loop})));
        pointsinds = unique(pointsinds(:), "stable");
        pointsinds(end+1) = pointsinds(1);
        points = geodata.Point(pointsinds);
        points = cell2mat(points(:));
        plot(0,0);
        axis([0 2.8 0 1.2]);
        axis equal;
        hold on
        xpts = points(:,1 );
        ypts = points(:,2 );
        plot(xpts, ypts, '-o');

        [Gcut, ix] = sliceGrid(Gcut, points, 'cutDir', dir);
        Gcut = repairNormals(Gcut);
        plotGrid(Gcut);axis equal tight;
    end
end
%%
plotGrid(Gcut);axis equal tight;


%% Plot loops
plot(0,0);
axis([0 2.8 0 1.2]);
axis equal;
hold on
for ifacies = 1:7
    loops = geodata.Facies{ifacies};
    numLoops = numel(loops);
    for iLoop = 1:numLoops
        loop = loops(iLoop);
        pointsinds = cell2mat(geodata.Line(abs(geodata.Loop{loop})));
        pointsinds = unique(pointsinds(:), "stable");
        pointsinds(end+1) = pointsinds(1);
        points = geodata.Point(pointsinds);
        points = cell2mat(points(:));
        xpts = points(:,1 );
        ypts = points(:,2 );
        plot(xpts, ypts, '-o');
    end
end

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