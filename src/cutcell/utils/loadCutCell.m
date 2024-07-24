function G = loadCutCell(nx, ny, varargin)
    opt = struct('dir', 'grid-files/cutcell');
    opt = merge_options(opt, varargin{:});
    fn = fullfile(opt.dir, sprintf("presplit_cutcell_%dx%d.mat", nx, ny));
    if isfile(fn)
        load(fn);
    else
        error("file %s does not exist.", fn)
    end
end
