function points = curveToPoints(curve, data)
%ex. curve = [1, 8, 3, 431, 2], list of lines
    pointsinds = cell2mat(data.Line(curve));
    pointsinds = unique(pointsinds(:), "stable");
    points = data.Point(pointsinds);
    points = cell2mat(points(:)); 
end