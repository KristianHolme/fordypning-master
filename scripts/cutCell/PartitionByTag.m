function partition = PartitionByTag(G)
    

    maincells = true(G.cells.num, 1);
    maincells(G.bufferCells) = false;
    volMax = max(G.cells.volumes(maincells));
    volLim = volMax/5;

    smallcellsLog = G.cells.volumes < volLim & G.cells.volumes > 0;
    nbs = getNeighbourship(G);
    smallCells = find(smallcellsLog);
    partition = (1:G.cells.num)';
    for ism = 1:numel(smallCells)
        c = smallCells(ism);
        n = nbs(nbs(:, 1) == c | nbs(:, 2) == c, :);
        n = unique(n(:));
        n = n(n~=c);
        n = n(G.cells.tag(n) == G.cells.tag(c));
        smallneighbors = ismember(n, smallCells);
        if numel(n) == 1
            finalneighbor = n;
        else
            f = G.cells.faces(G.cells.facePos(c):G.cells.facePos(c+1)-1); %faces of f
            faceneighbors = G.faces.neighbors(f,:); %neighbor cells
            f = f( ismember( faceneighbors(:,1), n ) | ismember( faceneighbors(:,2), n ) ); %faces that go to valid neighbor
            faceareas = G.faces.areas(f);
            faceneighbors = G.faces.neighbors(f,:);
            faceneighbors = faceneighbors(:,1) .* (faceneighbors(:,1) ~= c) + faceneighbors(:,2) .* (faceneighbors(:,2) ~= c);
    
            
            [~, sortorder] = sort(faceareas, 'descend');
            f = f(sortorder);
            faceneighbors = faceneighbors(sortorder);
            finalneighbor = faceneighbors(1);
        end
    
        partition(partition == c) = partition(finalneighbor); %cell and other cells assigned to it, gets reassigned
        
        % clf(gcf);
        % plotCellData(G, G.cells.tag);
        % plotGrid(G, c, 'facecolor', 'red');
        % 
        % plotGrid(G, [c, finalneighbor], 'facealpha', 0, 'linewidth', 3, 'edgecolor', 'red');
    end
    partition = compressPartition(partition);
end