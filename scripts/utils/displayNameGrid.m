function displayName = displayNameGrid(gridcase)
    switch gridcase
        case '5tetRef2'
            displayName = 'UU-M';
        case '5tetRef2-2D'
            displayName = 'UU-M-2D';
        case '6tetRef2'
            displayName = 'U-M';
        case '5tetRef1'
            displayName = 'UU-F';
        case '5tetRef4'
            displayName = 'UU-C';           
        case '6tetRef1'
            displayName = 'U-F';
        case 'semi203x72_0.3'
            displayName = 'SS-M';
        case 'struct220x90'
            displayName = 'S-M/F';
        case 'struct340x150'
            displayName = 'S-F';
        case 'struct193x83'
            displayName = 'S-M';
    end
end