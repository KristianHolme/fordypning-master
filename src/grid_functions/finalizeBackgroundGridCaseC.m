function G = finalizeBackgroundGridCaseC(G, opt)
    if opt.backgroundGridMap
        assert(strcmp(opt.SPEcase, 'C'))
        map = G.reportingGrid.map;
        I = map(:, 1);
        J = map(:, 2);
        W = map(:, 3);
        assert(max(I) <= 120*168)
        assert(max(J) == G.layerSize)
        layerI = {};
        layerJ = {};
        layerW = {};
        sz_background = 120;
        dy_rep = 1/sz_background;
        dy_mesh = 1/opt.Cdepth;
        for layerNo = 1:opt.Cdepth
            J_offset = J + (layerNo-1)*G.layerSize;
            x1 = (layerNo-1)*dy_mesh;
            x2 = x1 + dy_mesh;
            for layerNoBg = 1:sz_background
                y1 = (layerNoBg-1)*dy_rep;
                y2 = y1 + dy_rep;
                is_overlapping = max(x1,y1) <= min(x2,y2);
                overlap = min(x2,y2) - max(x1,y1);
                if is_overlapping
                    I_offset = I + (layerNoBg-1)*120*168;
                    assert(overlap >= 0)
                    if overlap > 1e-10
                        layerI{end+1} = I_offset;
                        layerJ{end+1} = J_offset;
                        layerW{end+1} = W.*overlap/dy_rep;
                    end
                else
                    assert(overlap <= 0)
                end
            end
        end
        G.reportingGrid.map = [vertcat(layerI{:}), vertcat(layerJ{:}), vertcat(layerW{:})];
    end
end