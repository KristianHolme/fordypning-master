function [gridcases, names] = getRSCGridcases(gridTypes, targetResolutions)
    % Grid configurations for different resolutions
    configs = struct();
    configs.r10k   = struct('nx', 140,  'nz', 75,  'qt', 1.34,   't', 1.28,   'sig', [2,2]);
    configs.r25k   = struct('nx', 420,  'nz', 60,  'qt', 0.81,   't', 0.762,  'sig', [2,3]);
    configs.r50k   = struct('nx', 500,  'nz', 100, 'qt', 0.56,  't', 0.527,  'sig', [2,3]);
    configs.r100k  = struct('nx', 840,  'nz', 120, 'qt', 0.394,  't', 0.366,  'sig', [3,3]);
    configs.r200k  = struct('nx', 1180, 'nz', 170, 'qt', NaN,  't', 0.256,  'sig', [3,3]);
    configs.r500k  = struct('nx', 1870, 'nz', 270, 'qt', NaN, 't', 0.16,  'sig', [3,2]);
    configs.r1000k = struct('nx', 2640, 'nz', 380, 'qt', NaN, 't', 0.113, 'sig', [3,3]);
    configs.r2000k = struct('nx', 3730, 'nz', 536, 'qt', NaN, 't', NaN, 'sig', [3,2]);
    
    % Grid type templates as a map
    templates = containers.Map();
    templates('C')    = struct('grid', @(c) sprintf('struct%dx%d', c.nx, c.nz), ...
                              'name', @(c) sprintf('b_C_%dx%d', c.nx, c.nz));
    templates('HC')   = struct('grid', @(c) sprintf('horz_ndg_cut_PG_%dx%d', c.nx, c.nz), ...
                              'name', @(c) sprintf('b_HC_%dx%d', c.nx, c.nz));
    templates('CC')   = struct('grid', @(c) sprintf('cart_ndg_cut_PG_%dx%d', c.nx, c.nz), ...
                              'name', @(c) sprintf('b_CC_%dx%d', c.nx, c.nz));
    templates('QT')   = struct('grid', @(c) sprintf('gq_pb%.*f', c.sig(1), c.qt), ...
                              'name', @(c) strrep(sprintf('b_QT%.*f', c.sig(1), c.qt), '.', '_'));
    templates('T')    = struct('grid', @(c) sprintf('5tetRef%.*f', c.sig(2), c.t), ...
                              'name', @(c) strrep(sprintf('b_T%.*f', c.sig(2), c.t), '.', '_'));
    templates('PEBI') = struct('grid', @(c) sprintf('cPEBI_%dx%d', c.nx, c.nz), ...
                              'name', @(c) sprintf('b_PEBI_%dx%d', c.nx, c.nz));
    
    gridcases = {};
    names = {};
    
    % Generate configurations for each resolution
    for res = targetResolutions
        resField = sprintf('r%dk', res);
        
        if ~isfield(configs, resField)
            warning('Unsupported resolution: %d', res);
            continue;
        end
        
        cfg = configs.(resField);
        
        % Add configurations for requested grid types
        for i = 1:length(gridTypes)
            type = upper(gridTypes{i});  % Convert to uppercase for consistency
            if ~templates.isKey(type)
                warning('Invalid grid type: %s', type);
                continue;
            end
            template = templates(type);
            gridcases{end+1} = template.grid(cfg);
            names{end+1} = template.name(cfg);
        end
    end
end