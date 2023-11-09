function bc = setupBC(G, varargin)
    opt = struct('experimental', false);
    opt = merge_options(opt, varargin{:});

    sat = [1, 0];
    if opt.experimental
        sat = [0,1,0];
    end
    topBCfaces = find(G.faces.centroids(:,3) < 1e-12);
    bc = addBC([], topBCfaces, 'pressure', 1.1e5*Pascal, ...
        'sat', sat);
end