function geoH = readHorizons(varargin)
    opt = struct('geoH', []);
    opt = merge_options(opt, varargin{:});
    if isempty(opt.geoH)
        geoH = readGeo('./geo-files/spe11a-horizons.geo');
    else
        geoH = opt.geoH;
    end
    removehorz = [5,7]; %remove difficult horizontals
    geoH.horz = geoH.horz(setdiff(1:size(geoH.horz, 1), removehorz)',:);
    geoH.horz(:, 3) = cellfun(@(curve)curveToPoints(curve, geoH), geoH.horz(:,2), UniformOutput=false);
    %Fix lowest horizon by adding the lower right corner point
    geoH.horz{end, 3} =  [geoH.horz{end, 3}; 2.8, 0, 0];
    % Making interpolation functions
    geoH.horz(:,4) = cellfun(@(points) interpolateHorizon(points), geoH.horz(:,3), UniformOutput=false);
    
    % Fix second lowest horizon, interpolate in middle between adjacent
    % horizons
    points = geoH.horz{8, 3};
    startx = points(end-1, 1);
    endx = points(end, 1);
    middlexs = linspace(startx, endx, 14);
    middlexs = middlexs(2:end-1);
    toph = geoH.horz{7, 4};
    topys = toph(middlexs);
    both = geoH.horz{9, 4};
    botys = both(middlexs);
    middleys = (topys + botys)./2;
    newpoints = horzcat(middlexs', middleys', zeros(numel(middleys), 1));
    points = vertcat(points(1:5,:), newpoints, points(end, :));
    geoH.horz{8, 3} = points;
    geoH.horz{8, 4} = interpolateHorizon(points);
end

function f = interpolateHorizon(points)
    xs = points(:,1);
    ys = points(:,2);
    f = @(newxs) interp1(xs, ys, newxs, 'linear');
end
