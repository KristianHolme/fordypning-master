function [partition, failed] = PartitionByTag(G, varargin)
    opt = struct('method', 'convexity', ...
        'vertIx', [], ...
        'avoidBufferCells', true);
    opt = merge_options(opt, varargin{:});
    if isempty(opt.vertIx)
        if max(G.cells.centroids(:,1)) > 1000
            opt.vertIx = 3;
        else
            opt.vertIx = 2;
        end
    end

    if ~isfield(G.faces,'nodesByFace')
        G.faces.nodesByFace = arrayfun(@(f)G.faces.nodes(G.faces.nodePos(f):G.faces.nodePos(f+1)-1), (1:G.faces.num)', UniformOutput=false);
    end
    
    maincells = true(G.cells.num, 1);
    maincells(G.bufferCells) = false;
    % volMax = max(G.cells.volumes(maincells));
    volLim = G.maxOrgVol/4;
    volLim2 = G.minOrgVol*10;
    % volLim = volMax/5;

    smallcellsLog = G.cells.volumes < volLim & G.cells.volumes > 0;
    nbs = getNeighbourship(G);
    smallCells = find(smallcellsLog);
    ignoreCells = [];
    if opt.avoidBufferCells
        ignoreCells = G.bufferCells;
        smallCells = setdiff(smallCells, ignoreCells);
    end
    %stuff
    switch opt.method
        case 'facearea'
            [partition, failed] = FaceAreaPartition(G, smallCells, nbs,  'ignoreCells', ignoreCells);
        case 'convexity'
            [partition, failed] = ConvexityPartition(G, smallCells, nbs, opt.vertIx,  'ignoreCells', ignoreCells);
    end
    partition = compressPartition(partition);
end

function [partition,failed] = FaceAreaPartition(G, smallCells, nbs,varargin)
    %group a small cell together with the same facies neighbor with the
    %biggest shared face
    opt = struct('ignoreCells', []);
    opt = merge_options(opt, varargin{:});

    partition = (1:G.cells.num)';
    failed = [];
    for ism = 1:numel(smallCells)
        c = smallCells(ism);
        n = nbs(nbs(:, 1) == c | nbs(:, 2) == c, :);
        n = unique(n(:));
        n = n(n~=c);
        n = n(G.cells.tag(n) == G.cells.tag(c));
        n = setdiff(n, opt.ignoreCells);
        if numel(n) == 1
            finalneighbor = n;
        else
            f = gridCellFaces(G, cells); %faces in partition
            faceneighbors = G.faces.neighbors(f,:); %neighbor cells
            %for each neighbor:sum shared area and sort
            interfaceareas = arrayfun(@(nb)sum(G.faces.areas(intersect(f, gridCellFaces(G, nb)))), n);
            [~,sortorder] = sort(interfaceareas, 'descend');

            % f = G.cells.faces(G.cells.facePos(c):G.cells.facePos(c+1)-1); %faces of f
            % faceneighbors = G.faces.neighbors(f,:); %neighbor cells
            % f = f( ismember( faceneighbors(:,1), n ) | ismember( faceneighbors(:,2), n ) ); %faces that go to valid neighbor
            % faceareas = G.faces.areas(f);
            % faceneighbors = G.faces.neighbors(f,:);
            % faceneighbors = faceneighbors(:,1) .* (faceneighbors(:,1) ~= c) + faceneighbors(:,2) .* (faceneighbors(:,2) ~= c);
            % [~, sortorder] = sort(faceareas, 'descend');
            % f = f(sortorder);


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
end

function [partition, failed] = ConvexityPartition(G, smallCells, nbs, vertIx, varargin)
    %group a small cell together with the same facies neighbor with the
    %biggest shared face
    opt = struct('ignoreCells', []);
    opt = merge_options(opt, varargin{:});
    partition = (1:G.cells.num)';
    
    [partition, failed] = mainConvexPartition(partition, smallCells, G, nbs, vertIx, opt);

    %try running again to see if we can catch more small cells
    maxtries = 10;
    tries = 1;

    while ~isempty(failed) && tries <= maxtries
        [partition, newfailed] = mainConvexPartition(partition, failed, G, nbs, vertIx, opt);
        if numel(newfailed) == numel(failed) && all(newfailed == failed)
            break
        else
            failed = newfailed;
        end
    end

    
end
function [partition, failed] = mainConvexPartition(partition, smallCells, G, nbs, vertIx, opt)
    failed = [];
    for ism = 1:numel(smallCells)
        c = smallCells(ism);
        currentPartition = partition(c);
        cells = find(partition == currentPartition);%all cells grouped with current cell
        neighbors = cell2mat(arrayfun(@(c) getnbs(G, nbs, c), cells, UniformOutput=false));
        neighbors = setdiff(neighbors, [opt.ignoreCells, cells']);
        neighborPartitions = unique(partition(neighbors));%find partitions of neighbors

        neighborPartitions = setdiff(neighborPartitions, currentPartition);%dont want current cells to be found as neighbors

        convexok = arrayfun(@(nbp)checkConvexMerge2(G, [cells;find(partition == nbp)], vertIx), neighborPartitions);
        

        neighborPartitions = neighborPartitions(convexok); %filter out neighbors that dont result in convexity
        neighborVolumes = arrayfun(@(nbp)sum(G.cells.volumes(partition == nbp)), neighborPartitions);
        currentPartitionVolume = sum(G.cells.volumes(partition == currentPartition));
        potentialVolumes = neighborVolumes + currentPartitionVolume;
        volumeok = potentialVolumes < G.maxOrgVol*2;
        neighborPartitions = neighborPartitions(volumeok);
        if isempty(neighborPartitions)
            failed = [failed;c];
            continue
        elseif numel(neighborPartitions) == 1
            finalneighborpartition = neighborPartitions;
        else
            f = gridCellFaces(G, cells); %faces in partition
            % nf = gridCellFaces(G, find(ismember(partition, neighborPartitions)));
            % faceneighbors = G.faces.neighbors(f,:); %neighbor cells
            %for each neighboring partition:sum shared area and sort
            interfaceareas = arrayfun(@(nbp)sum(G.faces.areas(intersect(f, gridCellFaces(G, find(partition==nbp))))), neighborPartitions);
            [~,sortorder] = sort(interfaceareas, 'descend');
            
            
            
            finalneighborpartition = neighborPartitions(sortorder(1));
        end        
        % clf(gcf);
        % % plotCellData(G, G.cells.tag);
        % plotGrid(G, cells, 'facecolor', 'red');view(0,0);
        % plotGrid(G, find(partition == finalneighborpartition), 'facealpha', 0, 'linewidth', 3, 'edgecolor', 'green');

        partition(cells) = finalneighborpartition; %cell and other cells assigned to it, gets reassigned
    end
end

function n = getnbs(G, nbs, c)
    n = nbs(nbs(:, 1) == c | nbs(:, 2) == c, :);
    n = unique(n(:));
    n = n(n~=c);
    n = n(G.cells.tag(n) == G.cells.tag(c));
end

function ok = checkConvexMerge2(G, cells, vertIx)
    tol = 1e-9;

    depthIx = 5-vertIx; %vertIx=3(z), depthIx is 2(y), and vice versa

    faces = unique(gridCellFaces(G, cells));
    externalfaces = xor(ismember(G.faces.neighbors(faces,1), cells), ismember(G.faces.neighbors(faces,2), cells));
    faces = faces(externalfaces);
    normals = G.faces.normals(faces, :) ./ G.faces.areas(faces);
    sideFaces = abs(normals(:,depthIx)) < tol;
    faces = faces(sideFaces); %now we have the interesting faces

    nodeOrdering = orderFaceNodes(G, faces, depthIx);
    %centroid of the cell connected to face of first node
   
    startcc = G.cells.centroids(intersect(G.faces.neighbors(faces(1),:), cells),:);
    startcc(depthIx) = 0.0;%move to plane
    v1 = G.nodes.coords(nodeOrdering(1),:) - startcc;
    v2 = G.nodes.coords(nodeOrdering(2),:) - startcc;
    % v1 = G.nodes.coords(nodeOrdering(1),:) - G.nodes.coords(nodeOrdering(2),:);
    % v2 = G.nodes.coords(nodeOrdering(3),:) - G.nodes.coords(nodeOrdering(2),:);
    crossprod = cross(v1, v2);
    sgn = sign(sum(crossprod)); %TODO maybe check against normal??
    % if vertIx == 3 %TODO check if this logic is correct
    %     sgn = sgn*-1;
    % end
    if sgn == 1
        nodeOrdering = nodeOrdering(end:-1:1);
    end
    %insert last node first and first node last to get looping
    nodeOrdering = [nodeOrdering(end);nodeOrdering;nodeOrdering(1)];
    nodecoords = G.nodes.coords(nodeOrdering,:);

    A = nodecoords(1:end-2,:);
    B = nodecoords(2:end-1,:);
    C = nodecoords(3:end, :);
    
    BA = A-B;
    BC = C-B;
    crossproducts = sum(cross(BA, BC), 2);

    okangles = crossproducts > 0 | abs(crossproducts)<tol;
    ok = all(okangles);
    % if ok
    %     color = 'green';
    % else
    %     color = 'red';
    % end
    % clf;
    % scatter3(B(:,1), B(:,2), B(:,3), 500, 1:size(B,1), 'filled');hold on;colorbar;view(0,0);
    % plotGrid(G, cells, 'facealpha', 0, 'edgecolor', color, 'linewidth', 3);
    % ;

end


function ok = checkConvexMerge(G, cells, vertIx)
    tol = 1e-9;
    ok = true;
    depthIx = 5-vertIx; %vertIx=3(z), depthIx is 2(y), and vice versa
    cellcentroids = G.cells.centroids(cells,:);
    volumes = G.cells.volumes(cells);
    weights = volumes/sum(volumes);
    avgcentroid = sum(times(cellcentroids, weights), 1);


    faces = unique(gridCellFaces(G, cells));
    externalfaces = xor(ismember(G.faces.neighbors(faces,1), cells), ismember(G.faces.neighbors(faces,2), cells));
    faces = faces(externalfaces);
    normals = G.faces.normals(faces, :);
    sideFaces = abs(normals(:,depthIx)) < tol;
    faces = faces(sideFaces); %now we have the interesting faces
    % normals = normals(sideFaces, :);
    % sgn = ismember(G.faces.neighbors(faces,1), cells)*2 - 1;
    % normals = bsxfun(@times, normals, sgn); %outward normals, check!

    ordering = orderFaces(G, faces); %faces(i) is neighboring faces(i+1) and faces(i-1) (mod(numel(faces))(?)) 
    faces = faces(ordering);
    faces =  [faces(end); faces];%wrap around
    normals = G.faces.normals(faces,:);
    normals = normals ./ G.faces.areas(faces); %normalize
    sgn = ismember(G.faces.neighbors(faces,1), cells)*2 - 1;
    normals = bsxfun(@times, normals, sgn); %outward normals, check!
    
    centroidToFace = G.faces.centroids(faces,:) - avgcentroid;%could use this to calculate ordering, but assuming convexity?
    normalsCrossProducts = sum(cross(normals(2:end,:), normals(1:end-1, :)),2);
    % dotProducts = dot(normals(2:end,:), normals(1:end-1, :), 2);
    centroidFaceCrossProducts = sum(cross(centroidToFace(2:end,:), centroidToFace(1:end-1, :)),2);
    
    %ok if crossproducts share sign or if normalcrossproducts are zero
    ok = all( (sign(normalsCrossProducts) == sign(centroidFaceCrossProducts)) | abs(normalsCrossProducts)<tol );
    % allfaces = zeros(G.faces.num, 1);allfaces(faces(2:end)) = 1:(numel(faces)-1);
    % clf;plotGrid(G, cells, 'facealpha', 0);plotFaceData(G, cells, allfaces);view(0,0);
end

function ordering = orderFaces(G, faces)
    faceNodes = vertcat(arrayfun(@(f)Faces2Nodes(f, G), faces, UniformOutput=false));
    neighbors = getFaceNeighbors(faceNodes);
    numfaces = numel(faces);
    ordering = zeros(numfaces, 1);
    ordering(1) = 1;
    ordering(2) = neighbors(1, 1);
    for i=3:numfaces
        ordering(i) = setdiff(neighbors(ordering(i-1),:), ordering(i-2));
    end
end

function nodesInOrder = orderFaceNodes(G, faces, depthIx)
    tol = 1e-10;
    faceNodes = arrayfun(@(f)Faces2Nodes(f, G), faces, UniformOutput=false);
    faceNodes = reshape(cell2mat(cellfun(@(fn)fn( abs(G.nodes.coords(fn,depthIx)) < tol ), faceNodes, UniformOutput=false)), 2,[])';

    % frontNodes = find(abs(G.nodes.coords(:,depthIx)) < tol); 
    % faceNodes = reshape(cell2mat(arrayfun(@(f)intersect(frontNodes,gridFaceNodes(G, f)), faces, UniformOutput=false)),2, [])';
    % 
    % faceNodes2 = reshape(cell2mat(arrayfun(@(f)intersect(frontNodes, Faces2Nodes(f, G)), faces, UniformOutput=false)),2, [])';
    
    
    numNodes = numel(unique(faceNodes(:)));
    nodesInOrder = zeros(numNodes, 1);
    % g = graph(faceNodes(:,1), faceNodes(:,2));
    nodesInOrder(1:2) = faceNodes(1,:);
    taken = false(size(faceNodes,1),1);
    taken(1,:) = true;

    % nodesInOrderOld = nodesInOrder;
    for i=3:numNodes
        % leftover = faceNodes(~takenrows,:);
        prevnode = nodesInOrder(i-1);
        % preprevnode = nodesInOrder(i-2);
        nextIx = flip(faceNodes == prevnode, 2);
        nextIx = nextIx & ~taken;
        taken(nextIx(:,1)|nextIx(:,2),:) = true;
        % prevnbs = neighbors(g, prevnode);
        % nextnode = sum(prevnbs) - preprevnode;
        
        nextnode = faceNodes(nextIx);
        
        nodesInOrder(i) = nextnode;
        % nodesInOrderOld(i) = setdiff(neighbors(g, nodesInOrderOld(i-1)), nodesInOrderOld(i-2));
    end
end

function nbs = getFaceNeighbors(faceNodes)
    n = numel(faceNodes);
    findNeighbors = @(face) find(arrayfun(@(i)~isempty(intersect(faceNodes{face}, faceNodes{i})) && face ~= i, 1:n));

    nbs = arrayfun(findNeighbors, (1:n)', UniformOutput=false);
    nbs = cell2mat(nbs);
end