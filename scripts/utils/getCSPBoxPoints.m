function [p1, p2] = getCSPBoxPoints(G, box, SPEcase)
    switch SPEcase
        case 'A'
            switch box
                case 'A'
                    x1 = 1.1;
                    x2 = 2.8;
                    z1 = 1.2;
                    z2 = 1.2-0.6;
                case 'B'
                    x1 = 0.0;
                    x2 = 1.1;
                    z1 = 1.2-0.6;
                    z2 = 1.2-1.2;
                case 'C'
                    x1 = 1.1;
                    x2 = 2.6;
                    z1 = 1.2-0.1;
                    z2 = 1.2-0.4;
            end
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
        case 'C'
            switch box
                case 'A'
                    x1 = 3300;
                    x2 = 8300;
                    z1 = 1200;
                    z2 = 1200-750;
                case 'B'
                    x1 = 100;
                    x2 = 3300;
                    z1 = 1200-750;
                    z2 = 1200-1350;
                case 'C'
                    x1 = 3300;
                    x2 = 7800;
                    z1 = 1200-250;
                    z2 = 1200-550;
            end
    end
    p1 = [x1 z2];
    p2 = [x2 z1];
end
