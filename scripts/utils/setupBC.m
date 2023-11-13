function bc = setupBC(G, varargin)
    opt = struct('experimental', false, ...
        'SPEcase', 'A');
    opt = merge_options(opt, varargin{:});

    sat = [1, 0];
    if opt.experimental
        sat = [0,1,0];
    end
    if strcmp(opt.SPEcase, 'A')
        press = 1.1*barsa;
    else
        press = 211.88658*barsa;
    end
    topBCfaces = find(G.faces.centroids(:,G.griddim) < 1e-12);
    bc = addBC([], topBCfaces, 'pressure', press, ...
        'sat', sat);
end