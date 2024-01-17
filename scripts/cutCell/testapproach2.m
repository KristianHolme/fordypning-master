clear all
close all

%%
geoH = readGeo('scripts\cutcell\geo\spe11a-horizons.geo');
removehorz = [5,7]; %remove difficult horizontals
geoH.horizons = geoH.horizons(setdiff(1:10, removehorz)',:);

%%

geoH.horizons(:, 3) = cellfun(@(curve)curveToPoints(curve, geoH), geoH.horizons(:,2), UniformOutput=false);
%%
disp("testing interp");
geoH.horizons(:,4) = cellfun(@(points) interpolateHorizon(points), geoH.horizons(:,3), UniformOutput=false);
%% Fix second lowest horizon
points = geoH.horizons{7, 3};
startx = points(end-1, 1);
endx = points(end, 1);
middlexs = linspace(startx, endx, 14);
middlexs = middlexs(2:end-1);
toph = geoH.horizons{6, 4};
topys = toph(middlexs);
both = geoH.horizons{8, 4};
botys = both(middlexs);
middleys = mean(topys + botys, 1);
newpoints = horzcat(middlexs', middleys', zeros(numel(middleys), 1));
points = vertcat(points(1:5,:), newpoints, points(end, :));
geoH.horizons{7, 3} = points;
geoH.horizons{7, 4} = interpolateHorizon(points);
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