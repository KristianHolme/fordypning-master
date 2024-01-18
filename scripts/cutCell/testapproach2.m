clear all
close all

%%
geoH = readHorizons();
geodata = readGeo('');
%%
Lx = 2.8;
Ly = 1.2;
nx = 1;
ny = 1;
G = cartGrid([nx ny 1], [Lx Ly 0.01]);
G =computeGeometry(G);
horzLines = horzcat(geoH.horz{:,2});
geoH.boundaryLines = setdiff(1:numel(geoH.Line), horzLines);
horzPoints = geoH.Line(horzLines);
horzPoints = unique([horzPoints{:}]);
%%
ptscoords = geoH.Point{horzPoints};

G = PointSplit(G, []);
%%
G = CutCellGeo(G, geoH);

%%
plotGrid(G);
%%
hold on 
plot(points(:,1), points(:,2), 'r-o');
%%
function points = curveToPoints(curve, data)
%ex. curve = [1, 8, 3, 431, 2], list of lines
    pointsinds = cell2mat(data.Line(curve));
    pointsinds = unique(pointsinds(:), "stable");
    points = data.Point(pointsinds);
    points = cell2mat(points(:)); 
end
function f = interpolateHorizon(points)
    xs = points(:,1);
    ys = points(:,2);
    f = @(newxs) interp1(xs, ys, newxs, 'linear');
end
function geoH = readHorizons()
    geoH = readGeo('scripts\cutcell\geo\spe11a-horizons.geo');
    removehorz = [5,7]; %remove difficult horizontals
    geoH.horz = geoH.horz(setdiff(1:10, removehorz)',:);
    geoH.horz(:, 3) = cellfun(@(curve)curveToPoints(curve, geoH), geoH.horz(:,2), UniformOutput=false);
    % Making interpolation functions
    geoH.horz(:,4) = cellfun(@(points) interpolateHorizon(points), geoH.horz(:,3), UniformOutput=false);
    
    % Fix second lowest horizon
    points = geoH.horz{7, 3};
    startx = points(end-1, 1);
    endx = points(end, 1);
    middlexs = linspace(startx, endx, 14);
    middlexs = middlexs(2:end-1);
    toph = geoH.horz{6, 4};
    topys = toph(middlexs);
    both = geoH.horz{8, 4};
    botys = both(middlexs);
    middleys = mean(topys + botys, 1);
    newpoints = horzcat(middlexs', middleys', zeros(numel(middleys), 1));
    points = vertcat(points(1:5,:), newpoints, points(end, :));
    geoH.horz{7, 3} = points;
    geoH.horz{7, 4} = interpolateHorizon(points);
end