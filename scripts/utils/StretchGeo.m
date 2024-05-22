function geodata = StretchGeo(geodata)
    points = vertcat(geodata.Point{:});
    points(:,1) = points(:,1)*3000;
    points(:,3) = points(:,3)*1000;

    geodata.Point = mat2cell(points, ones(1, size(points, 1)), 3);
end