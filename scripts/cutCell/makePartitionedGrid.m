function Gp = makePartitionedGrid(G, partition)
    Gp = G;
    Gp.cells = [];
    Gp.faces = [];
    Gp.cells.num = numel(unique(partition));
    Gp.cells.facePos = ones(Gp.cells.num+1,1);
    Gp.cells.faces = [];
    Gp.cells.volumes = zeros(Gp.cells.num,1);
    Gp.cells.centroids = zeros(Gp.cells.num, 3);
    Gp.nodes = G.nodes;
    Gp.faces.num = 0;
    Gp.faces.nodes = [];
    Gp.faces.nodePos = [1];
    Gp.faces.areas = [];
    Gp.faces.centroids = [];
    Gp.faces.normals = [];
    Gp.faces.neighbors = [];
    
    

    nbs = getNeighbourship(G);

    handledBlocks = [];
    partitionFaces = G.faces;
    for i =1:2
        nonzeros = partitionFaces.neighbors(:,i) ~= 0;
        partitionFaces.neighbors(nonzeros,i) = partition(partitionFaces.neighbors(nonzeros,i));
    end

    for ic = 1:Gp.cells.num
        currentPartition = ic;
        handledBlocks(end+1) = currentPartition;
        cells = find(partition == currentPartition);%all cells grouped with current cell
        Gp.cells.volumes(ic) = sum(G.cells.volumes(cells));
        volumeweights = G.cells.volumes(cells)/Gp.cells.volumes(ic);
        Gp.cells.centroids(ic,:) = mean(volumeweights'*G.cells.centroids(cells,:),1);

        neighbors = cell2mat(arrayfun(@(c) getnbs(G, nbs, c), cells, UniformOutput=false));
        neighbors = setdiff(neighbors,  cells);
        neighborPartitions = unique(partition(neighbors));%find partitions of neighbors

        neighborPartitions = setdiff(neighborPartitions, handledBlocks);%dont want current cells to be found as neighbors
        faces = gridCellFaces(G, cells);
        faces = faces(any(ismember(partitionFaces.neighbors(faces,:), [neighborPartitions;0]), 2));
        Gp = mergeFaces(G, Gp, partition, faces, cells);
    end
    %fix negative neighbors
    Gp.faces.neighbors(Gp.faces.neighbors < 0) = 0;
    Gp.faces.num = size(Gp.faces.areas,1);

    %assign faces to cells
    faces = arrayfun(@(ic)find(sum(Gp.faces.neighbors == ic, 2)), 1:Gp.cells.num, UniformOutput=false);
    numfaces = arrayfun(@(el)numel(el{1}), faces)';
    Gp.cells.facePos = cumsum([1;numfaces]);
    Gp.cells.faces = vertcat(faces{:});


    %remove unessecary nodes
    oldToNewNodes = zeros(Gp.nodes.num,1);
    uniqueNodes = unique(Gp.faces.nodes);
    Gp.nodes.num = numel(uniqueNodes);
    Gp.nodes.coords = Gp.nodes.coords(uniqueNodes,:);
    oldToNewNodes(uniqueNodes) = 1:Gp.nodes.num;
    Gp.faces.nodes = oldToNewNodes(Gp.faces.nodes);

    Gp.type = G.type;
    Gp.type{end+1} = 'makePartitionedGrid';

    Gp.faces.nodePos = Gp.faces.nodePos';
    checkGrid(Gp);
end

function Gp = mergeFaces(G, Gp, partition, faces, cells)
    %merge coplanar faces between two partition blocks
    currentPartition = partition(cells(1));
    nbs = G.faces.neighbors(faces,:);

    nbs = handleBdry(G, nbs, faces, Gp.cells.centroids(currentPartition,:));

    nbs = cell2mat(arrayfun(@(r)setdiff(nbs(r,:), cells), 1:size(nbs,1), UniformOutput=false))';
    nonNeg = nbs > 0;
    neighborBlocks = nbs;
    neighborBlocks(nonNeg) = partition(nbs(nonNeg));
    
    

    for in = 1:numel(unique(neighborBlocks))
        nblock = neighborBlocks(in);
        f = faces(neighborBlocks == nblock);
        %assuming cells are convex, so faces are coplanar
        nodes = gridFaceNodes(G, f(1));
        for i = 2:numel(f)
            nodes = setdiff(nodes, gridFaceNodes(G, f(i)));
        end
        area = sum(G.faces.areas(f));
        areaweights = G.faces.areas(f)/area;
        normal = mean(G.faces.normals(f,:), 1);
        normal = area*normal/norm(normal); %probably bad
        facecentroid = sum(areaweights.*G.faces.centroids(f,:),1);
        Gp.faces.nodes = [Gp.faces.nodes;nodes];
        Gp.faces.nodePos(end+1) = Gp.faces.nodePos(end) + numel(nodes);
        Gp.faces.areas = [Gp.faces.areas;area];
        celltoface = facecentroid - Gp.cells.centroids(currentPartition,:);
        %orient normal out of block
        normal = normal*sign(sum(celltoface .* normal,2));
        Gp.faces.normals = [Gp.faces.normals;normal];
        Gp.faces.neighbors = [ Gp.faces.neighbors;currentPartition, nblock];
        Gp.faces.centroids = [Gp.faces.centroids;facecentroid];
    end
end
function nbs = handleBdry(G, nbs, faces, cc)
    %handle boundary
    tol = 1e-6;
    bdryfaces = faces(any(nbs == 0,2));
    bdrynormals = G.faces.normals(bdryfaces,:);
    cc2fc = G.faces.centroids(bdryfaces,:) - cc;
    bdrynormals = bdrynormals.*sign(sum(cc2fc .* bdrynormals,2));
    bdryareas = G.faces.areas(bdryfaces);
    face2bdryblock = [0];%block for each face
    bdryblockids = [0];
    bdryblocknormals = bdrynormals(1,:)/bdryareas(1); %normal for each block
    for ibf = 2:numel(bdryfaces)
        match = abs(bdryblocknormals*bdrynormals(ibf,:)' - bdryareas(ibf)) < tol;
        if any(match)
            assert(sum(match) == 1);
            face2bdryblock(ibf) = bdryblockids(match);
        else
            face2bdryblock(ibf) = min(bdryblockids) - 1;
            bdryblocknormals(end+1,:) = bdrynormals(ibf,:)/bdryareas(ibf);
            bdryblockids(end+1) = face2bdryblock(ibf);
        end
    end
    nbs = nbs';
    nbs(nbs == 0) = face2bdryblock;
    nbs = nbs';
end

function n = getnbs(G, nbs, c)
    n = nbs(nbs(:, 1) == c | nbs(:, 2) == c, :);
    n = unique(n(:));
    n = n(n~=c);
end
