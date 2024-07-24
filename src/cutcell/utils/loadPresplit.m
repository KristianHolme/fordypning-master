function G = loadPresplit(nx, ny, varargin)
    opt = struct('dir', 'data/grid-files/cutcell/presplit');
    opt = merge_options(opt, varargin{:});
    fn = fullfile(opt.dir, sprintf("presplit_%dx%d.mat", nx, ny));
    if isfile(fn)
        load(fn);
    else
        error("file %s does not exist.", fn)
    end
end