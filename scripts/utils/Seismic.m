function customColormap = Seismic(dataMin, dataMax)% Define the size of the colormap
    n = 256;
    
    % Calculate the index where zero should be in the colormap
    zeroIndex = round(-dataMin / (dataMax - dataMin) * (n - 1)) + 1;
    
    % Initialize the colormap
    customColormap = zeros(n, 3);
    
    % Create the negative part of the colormap (red to white)
    for i = 1:zeroIndex
        customColormap(i, :) = [1, (i - 1) / (zeroIndex - 1), (i - 1) / (zeroIndex - 1)];
    end
    
    % Create the positive part of the colormap (white to blue)
    for i = zeroIndex:n
        customColormap(i, :) = [1 - (i - zeroIndex) / (n - zeroIndex), 1 - (i - zeroIndex) / (n - zeroIndex), 1];
    end
end
