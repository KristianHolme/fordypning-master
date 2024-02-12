function [p1, p2] = getCSPBoxPoints(G, box, SPEcase)
    switch SPEcase
        case 'B'
            switch box
                case 'A'
                    x1 = 3300;
                    x2 = 8300;
                    z1 = 1200;
                    z2 = 1200-600;
                case 'B'
                    x1 = 100;
                    x2 = 3300;
                    z1 = 1200-600;
                    z2 = 1200-1200;
                case 'C'
                    x1 = 3300;
                    x2 = 7800;
                    z1 = 1200-100;
                    z2 = 1200-400;
            end
    end
    p1 = [x1 z2];
    p2 = [x2 z1];
end
