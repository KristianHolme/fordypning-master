clear all
close all
%%
mrstModule add ad-core ad-props incomp mrst-gui mimetic linearsolvers ...
    ad-blackoil postprocessing diagnostics prosjektOppgave...
    deckformat gmsh nfvm mpfa
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
geodata.BoundaryLines = unique([1, 2, 12, 11, 9, 8, 10, 7, 6, 5, 3, 4, 24, 23, 22, 21, 20, 19, 18, 17, 16, 14, 15, 13]);
%% Define Background Grid
Lx = 2.8;
Ly = 1.2;
nx = 28;
ny = 12;
G = cartGrid([nx ny 1], [Lx, Ly 0.01]);
G = computeGeometry(G);
% G.nodes.coords(:,3) = 0;
% G = repairNormals(computeGeometry(G));
% G = repairNormals(G);
% plotGrid(G);axis tight equal;

%% Pre split cells, so nodes are never inside cells
% plot(0,0);
% hold on;
% plot(2.8, 1.2);
% Gcut = G;
% dir = [0 0 1];
eps = 1e-10;
numpoints = numel(geodata.Point);
Gcut = G;
dir = [0 0 1];
for ipoint = 1:numpoints
    
    point = geodata.Point{ipoint};
    % plot(point(1), point(2), 'ro');
    cell = findEnclosingCell(Gcut, point);
    if cell == 0
        if ipoint == numpoints
            break
        else
            continue
        end
    end
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
            splitpoints = [facexmin-eps point(2) 0; 
                           facexmax+eps point(2) 0];
        elseif splitdir == 2
            splitpoints = [point(1) faceymin-eps 0; 
                           point(1) faceymax+eps 0];
        end
        Gcut = sliceGrid(Gcut, splitpoints, 'cutDir', dir);
        % Gcut = repairNormals(computeGeometry(Gcut));
        % Gcut = repairNormals(Gcut);
        % plotGrid(Gcut, 'facealpha', 0, 'edgealpha', 0.2);
    end
end

%%
plotGrid(Gcut, 'facealpha', 0);axis tight;
ax = gca;
ax.TickLength = [0,0];

%% Main Cut based on individual lines

dir = [0 0 1];
% Gcut = computeGeometry(Gcut);
% Gcut = repairNormals(Gcut);
numlines = numel(geodata.Line);
for iline = 1:numlines
    dispif(iline >= 1, '%d\n', iline);
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




%% Plot loops
% plot(0,0);
% axis([0 2.8 0 1.2]);
% axis equal;
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
        plot(xpts, ypts, 'o');
    end
end

%%
Gcc = computeGeometry(Gcut);
Gcc = repairNormals(Gcc);
checkGrid(Gcc);