function  = loadCutCell(varargin)
    opt = struct('nx', 1, ...
                 'ny', 1, ...
                 'dir', 'grid-files/cutcell');
    opt = merge_options(opt, varargin{:});
    fn = fullfile(opt.dir, sprintf("cutcell_%dx%d.mat", opt.nx, opt.ny));
    if isfile(fn)
        load(fn);
    else
        error("file %s does not exist.", fn)
    end
end
