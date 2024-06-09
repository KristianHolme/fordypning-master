function G = rotateGrid(G)
    % Rotation matrix to rotate 90 degrees about X-axis
    % Transformation matrix to rotate -90 degrees about X-axis
    T = [1, 0, 0; 0, 0, 1; 0, -1, 0];

    if isfield(G, 'cells')%G is a grid
        pointSets = {'cells.centroids', 'faces.centroids', 'nodes.coords'};
        if isfield(G, 'parent')
            pointSets{3} = 'parent.nodes.coords';
        end
    elseif isfield(G, 'Point')%input is geodata
        G.Point = vertcat(G.Point{:});
        pointSets = {'Point'};
    else
        warning("Input is not grid or geodata!, returning input...")
        return
    end
    
    for i = 1:length(pointSets)
        pointSet = pointSets{i};
        subfields = strsplit(pointSet, '.');
        
        % Rotate points
        currentPoints = getfield(G, subfields{:});
        rotatedPoints = currentPoints * T';
        
        % Find original height (max y - min y)
        originalHeight = max(currentPoints(:, 2)) - min(currentPoints(:, 2));
        
        % Translate points down by original height
        rotatedPoints(:, 3) = rotatedPoints(:, 3) + originalHeight;
        
        % Update the field in G
        G = setfield(G, subfields{:}, rotatedPoints);
    end
    if isfield(G, 'type')
        G.type{end+1} = 'rotateGrid';
    else
        G.Point = mat2cell(G.Point, ones(1, size(G.Point, 1)), 3);
    end

end

