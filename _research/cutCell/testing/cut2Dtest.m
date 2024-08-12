close all
clear all

%%
geodata = readGeo('');
geodata.Facies{1} = [7, 8, 9, 32];
geodata.Facies{7} = [1, 31];
geodata.Facies{5} = [2, 3, 4, 5, 6];
geodata.Facies{4} = [10, 11, 12, 13, 14, 15, 22];
geodata.Facies{3} = [16, 17, 18, 19, 20, 21];
geodata.Facies{6} = [23, 24, 25];
geodata.Facies{2} = [26, 27, 28, 29, 30];
geodata.BoundaryLines = unique([1, 2, 12, 11, 9, 8, 10, 7, 6, 5, 3, 4, 24, 23, 22, 21, 20, 19, 18, 17, 16, 14, 15, 13]);
%% 
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
        pointsinds(end+1) = pointsinds(1); %connect start and end of loop
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