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
    Gp.faces.nodes = {};
    Gp.faces.nodePos = [1];
    Gp.faces.areas = -1*ones(G.faces.num, 1);
    Gp.faces.centroids = {};
    Gp.faces.normals = {};
    Gp.faces.neighbors = {};
    
    

    nbs = getNeighbourship(G);
    handledBlocks = false(Gp.cells.num, 1);
    curnumfaces = 0;

    %get partition-neighborship for faces
    partitionFaces = G.faces;
    for i =1:2
        nonzeros = partitionFaces.neighbors(:,i) ~= 0;
        partitionFaces.neighbors(nonzeros,i) = partition(partitionFaces.neighbors(nonzeros,i));
    end

    for ic = 1:Gp.cells.num
        currentPartition = ic;
        handledBlocks(currentPartition) = true;
        cells = find(partition == currentPartition);%all cells grouped with current cell
        Gp.cells.volumes(ic) = sum(G.cells.volumes(cells));
        volumeweights = G.cells.volumes(cells)/Gp.cells.volumes(ic);
        Gp.cells.centroids(ic,:) = mean(volumeweights'*G.cells.centroids(cells,:),1);

        neighbors = cell2mat(arrayfun(@(c) getnbs(G, nbs, c), cells, UniformOutput=false));
        neighbors = setdiff(neighbors,  cells);
        neighborPartitions = unique(partition(neighbors));%find partitions of neighbors

        neighborPartitions = setdiff(neighborPartitions, find(handledBlocks));%dont want current cells to be found as neighbors
        faces = gridCellFaces(G, cells);
        faces = faces(any(ismember(partitionFaces.neighbors(faces,:), [neighborPartitions;0]), 2));
        [Gp, curnumfaces] = mergeFaces(G, Gp, partition, faces, cells, curnumfaces);
    end
    %fix negative neighbors
    Gp.faces.neighbors = cell2mat(Gp.faces.neighbors');
    Gp.faces.neighbors(Gp.faces.neighbors < 0) = 0;
    %reformat
    Gp.faces.nodes = vertcat(Gp.faces.nodes{1:curnumfaces});
    Gp.faces.areas = Gp.faces.areas(Gp.faces.areas ~= -1);
    Gp.faces.num = size(Gp.faces.areas,1);
    Gp.faces.centroids = cell2mat(Gp.faces.centroids');
    Gp.faces.normals = cell2mat(Gp.faces.normals');
    

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

    Gp.cells.indexMap = (1:Gp.cells.num)';
    if isfield(G, 'bufferCells')
        Gp.bufferCells = partition(G.bufferCells)';
        Gp.bufferFaces = [];
    end

    assert(checkGrid(Gp), 'grid does not pas checkGrid!');
end

function [Gp, curnumfaces] = mergeFaces(G, Gp, partition, faces, cells, curnumfaces)
    %merge coplanar faces between two partition blocks
    currentPartition = partition(cells(1));
    nbs = G.faces.neighbors(faces,:);

    nbs = handleBdry(G, nbs, faces, Gp.cells.centroids(currentPartition,:));
    % nbs = cell2mat(arrayfun(@(r)setdiff(nbs(r,:), cells), 1:size(nbs,1), UniformOutput=false))';
    nbs = nbs';
    notInCells = ~ismember(nbs, cells);
    nbs = nbs(notInCells);
    
    nonNeg = nbs > 0;
    neighborBlocks = nbs;
    neighborBlocks(nonNeg) = partition(nbs(nonNeg));
    uniqueNeighBorBlocks = unique(neighborBlocks);

    for in = 1:numel(uniqueNeighBorBlocks)
        curnumfaces = curnumfaces +1;
        nblock = uniqueNeighBorBlocks(in);
        f = faces(neighborBlocks == nblock);
        %assuming cells are convex, so faces are coplanar

        area = sum(G.faces.areas(f));
        areaweights = G.faces.areas(f)/area;
        % normal = mean(G.faces.normals(f,:), 1);
        normal = G.faces.normals(f(1),:);
        normal = area*normal/norm(normal); %TODO probably bad
        facecentroid = sum(areaweights.*G.faces.centroids(f,:),1);
        
        Gp.faces.areas(curnumfaces) = area;
        celltoface = facecentroid - Gp.cells.centroids(currentPartition,:);
        %orient normal out of block
        normal = normal*sign(sum(celltoface .* normal,2));
        Gp.faces.normals{curnumfaces} = normal;
        Gp.faces.neighbors{curnumfaces} = [currentPartition, nblock];
        Gp.faces.centroids{curnumfaces} = facecentroid;

        %find which nodes are necessary
        % nodesOrdered = orderNodes(G, f, facecentroid, normal);
        % nodes = gridFaceNodes(G, f);
        nodes = Faces2Nodes(f, G);
        nodecoords = G.nodes.coords(nodes,:);
        %------------
        % clf;
        % scatter3(nodecoords(:,1),nodecoords(:,2), nodecoords(:,3), 500, (1:size(nodecoords,1))',  'filled');hold on;
        %-------------------------------------
        projcoords = (null(normal) .'*nodecoords')';
        chOrdering = convhull(projcoords);
        nodesOrdered = nodes(chOrdering(1:end-1));

        nodesOrderedLooped = [nodesOrdered(end);nodesOrdered;nodesOrdered(1)];
        nodecoords = G.nodes.coords(nodesOrderedLooped,:);
        %--------------------
        % plot3(nodecoords(:,1),nodecoords(:,2), nodecoords(:,3), 'b-o');
        %----------------------
        v1 = facecentroid-nodecoords(2,:);
        v2 = facecentroid-nodecoords(3,:);
        if sign(cross(v1, v2)*normal') == 1%make sure orientation is consistent
            nodecoords = nodecoords(end:-1:1, :);
            nodesOrdered = nodesOrdered(end:-1:1);
        end

        %normalize coords to avoid presicion errors bco skewness
        for i=1:3
            nodecoords(:,i) = nodecoords(:,i)/max(max(abs(nodecoords(:,i))),1);
        end
        A = nodecoords(1:end-2,:);
        B = nodecoords(2:end-1,:);
        C = nodecoords(3:end, :);
        BA = A-B;
        BC = C-B;
        
        roundpresicion = 13;
        keepnodes = sign(round(cross(BA, BC,2)*(normal/area)', roundpresicion)) == 1;
        assert(sum(keepnodes)>2, 'not enough nodes')
        nodes = nodesOrdered(keepnodes);

        nodes = nodes(end:-1:1);%revert direction to get positive computed cell volumes
        
        
        %------------
        % nodecoords = G.nodes.coords(nodes, :);
        % plot3(nodecoords(:,1),nodecoords(:,2), nodecoords(:,3), 'r--o');        
        % legend('all', 'convhull', 'final')
        %--------------

        % Gp.faces.nodes = [Gp.faces.nodes;nodes];
        Gp.faces.nodes{curnumfaces} = nodes; 
        Gp.faces.nodePos(end+1) = Gp.faces.nodePos(end) + numel(nodes);
    end
end

function n = Faces2Nodes(f, G)
    ni = mcolon(G.faces.nodePos(f), ...
                G.faces.nodePos(f+1)-1)';

    % pos = cumsum([1; double(nnode(f))]);
    n = G.faces.nodes(ni);
end

function nodes = orderNodes(G, faces, facecenter, facenormal)
    adjustfactor = 1e-12;
    nodes = unique(gridFaceNodes(G, faces));
    
    coords = G.nodes.coords(nodes,:);
    vecs = coords - facecenter;
    for i=1:3
        vecs(:,i) = vecs(:,i)/max(max(abs(vecs(:,i))),1);
    end
    
    % norms = sqrt(sum(vecs.^2,2));
    % vecs = vecs./ norms;
    refvec = vecs(1,:);
    dots = vecs(2:end,:) * refvec';
    angles = acos(dots*adjustfactor);
    assert(isreal(angles), "OrderNodes:angles are not real!");
    signs = sign(arrayfun(@(i)cross(refvec, vecs(i,:))*facenormal', 2:size(vecs,1)));
    values = (pi-angles).*signs';
    [~, sortorder] = sort(values);


    nodes = [nodes(1);nodes(sortorder+1)];

    nodecoords = G.nodes.coords(nodes,:);
    clf;plot3(nodecoords(:,1),nodecoords(:,2), nodecoords(:,3), '-o');hold on;
    plot3(facecenter(1), facecenter(2), facecenter(3), 'bo');
    ;


end

function nbs = handleBdry(G, nbs, faces, cc)
    %handle boundary
    tol = 1e-6;
    bdryfaces = faces(any(nbs == 0,2));
    bdrynormals = G.faces.normals(bdryfaces,:);
    cc2fc = G.faces.centroids(bdryfaces,:) - cc;
    bdryareas = G.faces.areas(bdryfaces);
    bdrynormals = ( bdrynormals.*sign(sum(cc2fc .* bdrynormals,2)) )./ bdryareas;
    face2bdryblock = [0];%block for each face
    bdryblockids = [0];
    bdryblocknormals = bdrynormals(1,:); %normal for each block
    for ibf = 2:numel(bdryfaces)
        match = abs(bdryblocknormals*bdrynormals(ibf,:)' - 1) < tol;
        if any(match)
            assert(sum(match) == 1);
            face2bdryblock(ibf) = bdryblockids(match);
        else
            face2bdryblock(ibf) = min(bdryblockids) - 1;
            bdryblocknormals(end+1,:) = bdrynormals(ibf,:);
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
