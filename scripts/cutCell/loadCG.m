function G = loadCG(nx, ny, varargin)
    opt = struct('dir', 'grid-files/cutcell');
    opt = merge_options(opt, varargin{:});
    fn = fullfile(opt.dir, sprintf("buff_presplit_cutcell_CG_%dx%d.mat", nx, ny));
    if isfile(fn)
        load(fn);
    else
        error("file %s does not exist.", fn)
    end
end