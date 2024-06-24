function bc = setupBC(G, varargin)
    opt = struct('experimental', false, ...
        'SPEcase', 'A');
    opt = merge_options(opt, varargin{:});

    sat = [1, 0];
    % sat = [0,1];
    if opt.experimental
        sat = [0,1,0];
    end
    if strcmp(opt.SPEcase, 'A')
        press = 1.1*barsa;
    else
        press = 2.0754e+07;
    end
    topBCfaces = find(G.faces.centroids(:,G.griddim) < 1e-12);
    bc = addBC([], topBCfaces, 'pressure', press, ...
        'sat', sat);
    if strcmp(opt.SPEcase, 'B') || strcmp(opt.SPEcase, 'C') %return no BC for B-case
        bc = [];
    end
end