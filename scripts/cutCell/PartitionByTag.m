function partition = PartitionByTag(G)

    volMax = max(G.cells.volumes);
    volLim = volMax/10;
    smallcellsLog = G.cells.volumes < volLim;
    nbs = getNeighbourship(G);
    smallCells = find(smallcellsLog);
    partition = (1:G.cells.num)';
    for ism = 1:numel(smallCells)
        c = smallCells(ism);
        n = nbs(nbs(:, 1) == c | nbs(:, 2) == c, :);
        n = unique(n(:));
        n = n(n~=c);
        n = n(G.cells.tag(n) == G.cells.tag(c));
        if numel(n) == 1
            finalneighbor = n;
        else
    
            f = G.cells.faces(G.cells.facePos(c):G.cells.facePos(c+1)-1);
            faceneighbors = G.faces.neighbors(f,:);
            f = f( ismember( faceneighbors(:,1), n ) | ismember( faceneighbors(:,2), n ) );
            faceareas = G.faces.areas(f);
            faceneighbors = G.faces.neighbors(f,:);
            faceneighbors = faceneighbors(:,1) .* (faceneighbors(:,1) ~= c) + faceneighbors(:,2) .* (faceneighbors(:,2) ~= c);
    
            [~, sortorder] = sort(faceareas, 'descend');
            f = f(sortorder);
            faceneighbors = faceneighbors(sortorder);
            finalneighbor = faceneighbors(1);
        end
    
        partition(c) = partition(finalneighbor);
        % clf(gcf);
        % plotCellData(G, G.cells.tag);
        % plotGrid(G, [c, finalneighbor], 'facealpha', 0, 'linewidth', 3, 'edgecolor', 'red');
    end

end