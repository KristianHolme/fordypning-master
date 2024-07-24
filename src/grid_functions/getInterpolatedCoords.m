function coords = getInterpolatedCoords(G, varargin)
    %get coordinates from relative coordinates by interpolating between
    %bounds
    % Initialize variables
    xcoord = [];
    ycoord = [];
    zcoord = [];
    
    % Extract min and max coordinates
    xMin = min(G.nodes.coords(:,1));
    xMax = max(G.nodes.coords(:,1));
    yMin = min(G.nodes.coords(:,2));
    yMax = max(G.nodes.coords(:,2));
    zMin = min(G.nodes.coords(:,3));
    zMax = max(G.nodes.coords(:,3));
    
    % Parse optional input arguments
    for i = 1:2:length(varargin)
        switch varargin{i}
            case 'xrel'
                xrel = varargin{i+1};
                xcoord = xMin * (1-xrel) + xMax * (xrel);
            case 'yrel'
                yrel = varargin{i+1};
                ycoord = yMin * (1-yrel) + yMax * (yrel);
            case 'zrel'
                zrel = varargin{i+1};
                zcoord = zMin * (zrel) + zMax * (1-zrel); % 1 corresponds to top of reservoir
            otherwise
                error('Invalid input');
        end
    end
    coords = [xcoord, ycoord, zcoord];
    coords = coords(~isnan(coords));
end