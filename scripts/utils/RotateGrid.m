function G = RotateGrid(G)
    % Rotation matrix to rotate 90 degrees about X-axis
    % Transformation matrix to rotate -90 degrees about X-axis
    T = [1, 0, 0; 0, 0, 1; 0, -1, 0];
    
    pointSets = {'cells.centroids', 'faces.centroids', 'nodes.coords'};
    
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
    G.type{end+1} = 'RotateGrid';
end

