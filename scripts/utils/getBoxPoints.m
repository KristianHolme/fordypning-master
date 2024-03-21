function [p1, p2] = getBoxPoints(name, SPEcase, griddim)
    switch name
        case ''
            x1 = -1;
            x2 = 3;
            z1 = -1;
            z2 = 2;           
        case 'uppermiddle'
            x1 = 0.859267;
            x2 = 1.61156;
            z1 = 0.099;
            z2 = 0.5586;
        case 'middle'
            x1 = 3950/3000;
            x2 = 4050/3000;
            z1 = 650/1000;
            z2 = 750/1000;
        
    end
    if griddim == 3
        p1 = [x1 z1];
        p2 = [x2, z2];
    else
        p1 = [x1 1.2 - z2];
        p2 = [x2, 1.2 - z1];
    end

    if strcmp(SPEcase, 'B')
        p1(1) = p1(1)*3000;
        p1(2) = p1(2)*1000;

        p2(1) = p2(1)*3000;
        p2(2) = p2(2)*1000;
    end
end