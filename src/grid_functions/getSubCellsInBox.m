function subcells = getSubCellsInBox(G, p1, p2)
    %calculates the cells with centers inside a box specified by points p1
    %and p2
    %if grid is 3d, p1 is upper left corner and p2 is lower right
    %if grid is 2d, p1 is lower left, p2 upper right
    %return value subcells is logical array
    x1 = p1(1);
    x2 = p2(1);

    z2 = p2(2);
    z1 = p1(2);
    centroids = G.cells.centroids;

    if G.griddim == 3
        updim = 3;
    else
        updim = 2;
    end

    insidex = centroids(:, 1) > x1 & centroids(:,1 ) < x2;
    insidez = centroids(:, updim)> z1 & centroids(:,updim ) < z2;
    subcells = insidez & insidex;

end