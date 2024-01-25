function partition = PartitionByTag(G, varargin)
    opt = struct('method', 'facearea', ...
        'vertIx', []);
    opt = merge_options(opt, varargin{:});
    if isempty(opt.vertIx)
        if max(G.cells.centroids(:,1)) > 1000
            opt.vertIx = 3;
        else
            opt.vertIx = 2;
        end
    end
    
    maincells = true(G.cells.num, 1);
    maincells(G.bufferCells) = false;
    volMax = max(G.cells.volumes(maincells));
    volLim = volMax/5;

    smallcellsLog = G.cells.volumes < volLim & G.cells.volumes > 0;
    nbs = getNeighbourship(G);
    smallCells = find(smallcellsLog);
    %stuff
    switch opt.method
        case 'facearea'
            partition = FaceAreaPartition(G, smallCells, nbs);
        case 'convexity'
            partition = ConvexityPartition(G, smallCells, nbs, opt.vertIx);
    end
    partition = compressPartition(partition);
end

function partition = FaceAreaPartition(G, smallCells, nbs)
    %group a small cell together with the same facies neighbor with the
    %biggest shared face
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

function partition = ConvexityPartition(G, smallCells, nbs, vertIx)
    %group a small cell together with the same facies neighbor with the
    %biggest shared face
    partition = (1:G.cells.num)';
    for ism = 1:numel(smallCells)
        c = smallCells(ism);
        n = nbs(nbs(:, 1) == c | nbs(:, 2) == c, :);
        n = unique(n(:));
        n = n(n~=c);
        n = n(G.cells.tag(n) == G.cells.tag(c));
        convexok = arrayfun(@(cellnb)checkConvexMerge(G, [c;cellnb], vertIx), n); %check correct

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

function ok = checkConvexMerge(G, cells, vertIx)
    tol = 1e-11;
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
    normals = normals(sideFaces, :);
    sgn = ismember(G.faces.neighbors(faces,1), cells)*2 - 1;
    normals = bsxfun(@times, normals, sgn); %outward normals, check!

    ordering = orderFaces(G, faces); %faces(i) is neighboring faces(i+1) and faces(i-1) (mod(numel(faces))(?)) 
    faces = faces(ordering);
    faces =  [faces(end); faces];%wrap around
    normals = G.faces.normals(faces,:);
    normals = normals ./ G.faces.areas(faces); %normalize
    sgn = ismember(G.faces.neighbors(faces,1), cells)*2 - 1;
    normals = bsxfun(@times, normals, sgn); %outward normals, check!
    
    centroidToFace = G.faces.centroids(faces,:) - avgcentroid;%could use this to calculate ordering, but assuming convexity?
    normalsCrossProducts = sum(cross(normals(2:end,:), normals(1:end-1, :)),2);
    dotProducts = dot(normals(2:end,:), normals(1:end-1, :), 2);
    centroidFaceCrossProducts = sum(cross(centroidToFace(2:end,:), centroidToFace(1:end-1, :)),2);
    
    %ok if crossproducts share sign or if normalcrossproducts are zero
    ok = all( (sign(normalsCrossProducts) == sign(centroidFaceCrossProducts)) | abs(normalsCrossProducts)<tol );
    allfaces = zeros(G.faces.num, 1);allfaces(faces(2:end)) = 1:(numel(faces)-1);
    clf;plotGrid(G, cells, 'facealpha', 0);plotFaceData(G, cells, allfaces);view(0,0);
end

function ordering = orderFaces(G, faces)
    faceNodes = vertcat(arrayfun(@(f)gridFaceNodes(G, f), faces, UniformOutput=false));
    neighbors = getFaceNeighbors(faceNodes);
    numfaces = numel(faces);
    ordering = zeros(numfaces, 1);
    ordering(1) = 1;
    ordering(2) = neighbors(1, 1);
    for i=3:numfaces
        ordering(i) = setdiff(neighbors(ordering(i-1),:), ordering(i-2));
    end
end

function nbs = getFaceNeighbors(faceNodes)
    n = numel(faceNodes);
    findNeighbors = @(face) find(arrayfun(@(i)~isempty(intersect(faceNodes{face}, faceNodes{i})) && face ~= i, 1:n));

    nbs = arrayfun(findNeighbors, (1:n)', UniformOutput=false);
    nbs = cell2mat(nbs);
end