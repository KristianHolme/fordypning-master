function G = GenerateCutCellGrid(nx, ny, varargin)
    opt = struct('save', true, ...
        'savedir', 'grid-files/cutcell', ...
        'verbose', false, ...
        'waitbar', false, ...
        'presplit', true, ...
        'recombine', true, ...
        'bufferVolumeSlice', false);
    opt = merge_options(opt, varargin{:});

    Lx = 2.8;
    Ly = 1.2;
    G = cartGrid([nx ny 1], [Lx, Ly 0.01]);
    G = computeGeometry(G);  

    % Read geodata and add facies and boundary
    
    configFile = fileread('config.JSON');
    config = jsondecode(configFile);
    fn = fullfile(config.geo_folder, 'spe11a.geo');
    %fn = 'C:\Users\holme\Documents\Prosjekt\Prosjektoppgave\src\11thSPE-CSP\geometries\spe11a.geo';
    geodata = readGeo(fn);
    %assign loops to Fascies
    geodata.Facies{1} = [7, 8, 9, 32];
    geodata.Facies{7} = [1, 31];
    geodata.Facies{5} = [2, 3, 4, 5, 6];
    geodata.Facies{4} = [10, 11, 12, 13, 14, 15, 22];
    geodata.Facies{3} = [16, 17, 18, 19, 20, 21];
    geodata.Facies{6} = [23, 24, 25];
    geodata.Facies{2} = [26, 27, 28, 29, 30];
    geodata.BoundaryLines = unique([1, 2, 12, 11, 9, 8, 10, 7, 6, 5, 3, 4, 24, 23, 22, 21, 20, 19, 18, 17, 16, 14, 15, 13]);
    
    

    if opt.bufferVolumeSlice
        %slicing close to sides to create buffer volume cells
        G = sliceGrid(G, {[0.000333333333, 0.5, 0], [2.79966666666, 0.5, 0]}, 'normal', [1 0 0]);
    end
    if opt.presplit
        G = PointSplit(G, geodata.Point, 'verbose', opt.verbose, 'waitbar', opt.waitbar, ...
            'save', opt.save, 'savedir', fullfile(opt.savedir, 'presplit'), 'bufferVolumeSlice', opt.bufferVolumeSlice);
    end
    G = CutCellGeo(G, geodata, 'verbose', opt.verbose, 'save', opt.save, 'savedir', opt.savedir, ...
        'presplit', opt.presplit, 'bufferVolumeSlice', opt.bufferVolumeSlice);
    
    G = removeCells(G, G.cells.tag == 7); %remove here, RemoveCells doesnt work on CG
    G.cells.tag = G.cells.tag(G.cells.tag ~= 7);
    if opt.recombine
        t = tic();
        partition = PartitionByTag(G);
        compressedPartition = compressPartition(partition);
        CG = generateCoarseGrid(G, compressedPartition);
        CG = coarsenGeometry(CG);
        % CGcellToGCell = unique(partition);
        CG.cells.tag = G.cells.tag(unique(partition));
        % CG = TagbyFacies(CG, geodata);
        t = toc(t);
        dispif(opt.verbose, "Partition and coarsen in %0.2f s\n", t);
        G = CG;
        if opt.save
            if opt.presplit
                fn = sprintf('presplit_cutcell_CG_%dx%d.mat', nx, ny);
            else
                fn = sprintf('cutcell_CG_%dx%d.mat', nx, ny);
            end
            if opt.bufferVolumeSlice
                fn = ['buff_', fn];
            end
            
            save(fullfile(opt.savedir, fn), "G");
        end
    end
end
