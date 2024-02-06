function n = getCellNeighborsByNode(G,c, varargin)
    opt = struct('n', []);
    opt = merge_options(opt, varargin{:});
    if isempty(opt.n)
        n = neighboursByNodes(G);
    else 
        n = opt.n;
    end
    n = n(n(:, 1) == c | n(:, 2) == c, :);
    n = unique(n(:));
    n = n(n~=c);
end