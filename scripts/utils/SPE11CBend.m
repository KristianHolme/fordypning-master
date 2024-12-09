function new_coord = SPE11CBend(coord)
    assert(size(coord, 2) == 3)
    x = coord(:, 1);
    y = coord(:, 2);
    z = coord(:, 3);
    
    tmp = 1 - ((y - 2500)/2500).^2;
    w = z - 150.*tmp - y./500;
    
    new_coord = [x, y, w];
end
