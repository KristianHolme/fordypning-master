function displayName = displayNameGrid(gridcase, specase)
    Amap = containers.Map;
    Amap('5tetRef2') = 'UU-M';
    Amap('5tetRef3') = 'UU-C';
    Amap('5tetRef2-2D') = 'UU-M-2D';
    Amap('6tetRef2') = 'U-M';
    Amap('6tetRef3') = 'U-C';
    Amap('5tetRef1') = 'UU-F';
    Amap('5tetRef4') = 'UU-C';
    Amap('6tetRef1') = 'U-F';
    Amap('semi203x72_0.3') = 'SS-M';
    Amap('struct220x90') = 'S-M/F';
    Amap('struct340x150') = 'S-F';
    Amap('struct193x83') = 'S-M';
    
    Bmap = containers.Map;
    Bmap('5tetRef0.4') = 'UU-F';
    Bmap('5tetRef0.8') = 'UU-M';
    Bmap('5tetRef2') = 'UU-C';
    Bmap('6tetRef2') = 'U-C';
    Bmap('6tetRef0.8') = 'U-M';

    if strcmp(lower(specase), 'a')
        if isKey(Amap, gridcase)
            displayName = Amap(gridcase);
        else
            displayName = gridcase;
        end
    elseif strcmp(lower(specase), 'b')
        if isKey(Bmap, gridcase)
            displayName = Bmap(gridcase);
        else
            displayName = gridcase;
        end
    end

    
    
end