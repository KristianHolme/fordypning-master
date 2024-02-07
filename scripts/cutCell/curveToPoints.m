function pts = curveToPoints(curve, data, varargin)
    opt = struct('indices', false);
    opt = merge_options(opt, varargin{:});
    %ex. curve = [1, 8, 3, 431, 2], list of lines
    pointsinds = cell2mat(data.Line(curve));
    pointsinds = unique(pointsinds(:), "stable");
    points = data.Point(pointsinds);
    points = cell2mat(points(:)); 
    if opt.indices
        pts = pointsinds;
    else
        pts = points;
    end
end