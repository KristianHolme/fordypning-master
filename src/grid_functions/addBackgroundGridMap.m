function G = addBackgroundGridMap(G, opt)
    if opt.backgroundGridMap
        nz = 1;
        if strcmp(opt.SPEcase, 'A')
            % 280 x 120
            nx = 280;
            ny = 120;
            error('Not fixed yet.')
        elseif strcmp(opt.SPEcase, 'B')
            % 840 x 120
            nx = 840;
            ny = 120;
        else
            % 168 x 100 x 120
            nx = 168;
            ny = 100;
            nz = 120;
            assert(strcmp(opt.SPEcase, 'C'))
        end
        %check if the grid is already reduced
        if ~isfield(G, 'reductionMatrix') || size(G.reductionMatrix, 1) ~= nx*120
            [M, Gr, report] = getReductionMatrix(G, nx, 120);
            G.reductionMatrix = M;
            G.reductionGrid = Gr;
            G.reductionReport = report;
        else
            M = G.reductionMatrix;
        end
        [I, J, V] = find(M);
        G.reportingGrid = struct('map', [I, J, V], 'dims', [nx, ny, nz]);
    else
        G.reportingGrid = [];
    end
end