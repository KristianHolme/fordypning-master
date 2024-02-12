function c = getCSPBoxCells(G, box, SPEcase)
    [p1, p2] = getCSPBoxPoints(G, box, SPEcase);
    c = getSubCellsInBox(G, p1, p2);
end
