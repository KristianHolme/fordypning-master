function G = loadPresplit(varargin)
    opt = struct('nx', 1, ...
                 'ny', 1, ...
                 'dir', 'grid-files/cutcell/presplit');
    opt = merge_options(opt, varargin{:});
    fn = fullfile(opt.dir, sprintf("presplit_%dx%d.mat", opt.nx, opt.ny));
    if isfile(fn)
        load(fn);
    else
        error("file %s does not exist.", fn)
    end
end