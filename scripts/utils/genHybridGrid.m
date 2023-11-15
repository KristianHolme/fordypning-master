function G = genHybridGrid(varargin)
    opt = struct('nx', 200, ...
                 'nz', 150, ...
                 'density', 0.5, ...
                 'savegrid', false, ...
                 'plotUnstructured', false, ...
                 'verbose', false, ...
                 'version', 'A');
    % Grid genereation code from https://github.com/vetlenev/Master-Thesis/blob/main/FluidFlower/hybridGrid_FluidFlower.m
    opt = merge_options(opt, varargin{:});
    nx_glob = opt.nx;
    nz_glob = opt.nz;
    node_density = opt.density;
    verbose = opt.verbose;
    plotUnstructured = opt.plotUnstructured;
    savepath = ['grid-files\spe11a_semi', ...
    num2str(nx_glob), 'x', num2str(nz_glob), '_', num2str(node_density), '_grid.mat'];

    mrstModule add matlab_bgl coarsegrid
    addpath("Nevland\FluidFlower\SPE11-utils\");
    addpath("Nevland\FluidFlower\grid");
    
    
    filename = ['11thSPE-CSP/geometries/spe11', lower(opt.version), '.geo'];
    [pts, loops, facies] = parse_spe11_geo(filename, 'verbose', verbose);

    % Other definitions
    poly = struct; % to hold each polynomial
    pts_overlap = struct; % to hold overlapping polygonal points (provided from data file)
    nodes_overlap = struct; % to hold overlapping nodes from generated subgrids
    
    logicalBottom = @(G) G.nodes.coords(:,2) == min(G.nodes.coords(:,2));
    logicalTop = @(G) G.nodes.coords(:,2) == max(G.nodes.coords(:,2));
    
    gravity reset on
    
    % Global grid
    [G_glob, x_glob, z_glob] = PolygonGrid.globalCartGrid(pts, nx_glob, nz_glob);
    
    Lx = max(G_glob.faces.centroids(:,1));
    Lz = max(G_glob.faces.centroids(:,2));
    N = G_glob.cartDims;
    Nx = N(1); Nz = N(2);
    
    % Organize polygons
    polys = PolygonGrid.polyPoints(pts, loops, facies);
    % Upper, fully horizontally extending surface: 32
    poly.top = PolygonGrid(polys, 32);
    
    ptop_orig = poly.top.p_orig;
    ptop = poly.top.p;
    poly.top.p_idx = 'p32';
    
    % Find top and bottom surfaces
    [poly.top, split_pts] = reorderPts(poly.top, 32);
    
    [top_side, bottom_side] = topAndBottomSurfaces(poly.top, split_pts, 32, pts_overlap);
    poly.top.top_side = top_side;
    poly.top.bottom_side = bottom_side;
    
    poly.top = cartesianSubgrid(poly.top, Lx, Lz, Nx, Nz, []); % []: no conforming of horizontal grid size
    
    % dx-correction
    % For each surface point, find closest x-coord in subgrid and change it to
    % equal the surface coordinate
    poly.top.bottom_mask = logicalBottom(poly.top.G); % only select nodes at bottom of grid
    poly.top.top_mask = logicalTop(poly.top.G);
    poly.top.G = computeGeometry(poly.top.G);
    % Bottom:
    [poly.top, closest_bottom] = correct_dx_poly(poly.top, G_glob, poly.top.bottom_mask, 'bottom');
    % Top:
    [poly.top, closest_top] = correct_dx_poly(poly.top, G_glob, poly.top.top_mask, 'top');
    
    % Interpolation
    % Interpolate z-values at surface of polygon
    poly.top = interpolateZ_remaining(poly.top, closest_bottom, ...
                                    poly.top.bottom_mask, 'bottom', 'linear'); % top face is the "remaining" parts of the polygon we want bottom surface
    poly.top = interpolateZ_remaining(poly.top, closest_top, ...
                                    poly.top.top_mask, 'top', 'linear');
    
    % Interpolate x+z values in interior
    poly.top = interpolateInternal(poly.top, poly.top.top_mask, poly.top.bottom_mask, []);
    
    % Finally, update grid
    poly.top.G = computeGeometry(poly.top.G);
    [ii, jj] = gridLogicalIndices(poly.top.G);
    poly.top.G.i = ii;
    poly.top.G.j = max(jj) - jj + 1; % To make lowest index start from top and increase downwards
    
    Gtop = poly.top.G;
    ptop_bottom = poly.top.bottom_side;
    ptop_top = poly.top.top_side;
    
    % Rename to polygon idx
    poly = cell2struct(struct2cell(poly), {'p32'});
    
    % Create subgrid for neighboring polygon below
    [poly, nodes_overlap, pts_overlap] = glueToUpperPolygon(polys, poly, 30, 32, ...
                                                            nodes_overlap, pts_overlap, G_glob);
    
    [poly, nodes_overlap, pts_overlap] = glueToUpperPolygon(polys, poly, 28, 32, ...
                                                            nodes_overlap, pts_overlap, G_glob);
    
    [poly, nodes_overlap, pts_overlap] = gluePinchOuts(polys, poly, 29, 32, 25, ...
                                                         nodes_overlap, pts_overlap, G_glob);
    
    
    [poly, nodes_overlap, pts_overlap] = glueToUpperPolygon(polys, poly, 18, 30, ...
                                                            nodes_overlap, pts_overlap, G_glob, true, 1.5);
    
    [poly, nodes_overlap, pts_overlap] = glueToUpperPolygon(polys, poly, 13, 18, ...
                                                            nodes_overlap, pts_overlap, G_glob);
    
    [poly, nodes_overlap, pts_overlap] = glueToUpperPolygon(polys, poly, 20, 28, ...
                                                            nodes_overlap, pts_overlap, G_glob);
    
    [poly, nodes_overlap, pts_overlap] = glueToUpperPolygon(polys, poly, 15, 20, ...
                                                            nodes_overlap, pts_overlap, G_glob);
    
    [poly, nodes_overlap, pts_overlap] = glueToUpperPolygon(polys, poly, 6, 15, ...
                                                            nodes_overlap, pts_overlap, G_glob);
    
    % Create subgrids around pinch-outs
    [poly, nodes_overlap, pts_overlap] = gluePinchOuts(polys, poly, 5, 13, 12, ...   
                                                         nodes_overlap, pts_overlap, G_glob);
    
    
    % For polygon 19, upper neighbor contains pinch-out
    [poly, nodes_overlap, pts_overlap] = gluePinchOuts(polys, poly, 19, 29, 25, ...
                                                         nodes_overlap, pts_overlap, G_glob);
    
    % Continue downwards until polygon 11 -> this one must be implemented manually
    %For polygon 14, upper neighbor contains pinch-out -> handled internally in
    %glueToUpperPolygon
    [poly, nodes_overlap, pts_overlap] = glueToUpperPolygon(polys, poly, 14, 19, ...
                                                            nodes_overlap, pts_overlap, G_glob);
    
    [poly, nodes_overlap, pts_overlap] = glueToUpperPolygon(polys, poly, 4, 14, ...
                                                            nodes_overlap, pts_overlap, G_glob, false); % Leftmost cells become very thin if inter_horz=false !
    
    [poly, nodes_overlap, pts_overlap] = glueToUpperPolygon(polys, poly, 27, 6, ...
                                                            nodes_overlap, pts_overlap, G_glob, false);
    
    [poly, nodes_overlap, pts_overlap] = glueToUpperPolygon(polys, poly, 17, 6, ...
                                                            nodes_overlap, pts_overlap, G_glob, false);
    
    % Handle polygon 11
    [poly, nodes_overlap, pts_overlap] = gluePolygon11(polys, poly, 11, [17,4,5], ...
                                                         nodes_overlap, pts_overlap, G_glob);
    
    % Continue downwards on both sides of bottom fault
    [poly, nodes_overlap, pts_overlap] = glueToUpperPolygon(polys, poly, 16, 27, ...
                                                            nodes_overlap, pts_overlap, G_glob);
    
    [poly, nodes_overlap, pts_overlap] = glueToUpperPolygon(polys, poly, 10, 16, ...
                                                            nodes_overlap, pts_overlap, G_glob);
    
    [poly, nodes_overlap, pts_overlap] = glueToUpperPolygon(polys, poly, 8, 10, ...
                                                            nodes_overlap, pts_overlap, G_glob);
    
    [poly, nodes_overlap, pts_overlap] = glueToUpperPolygon(polys, poly, 3, 8, ...
                                                            nodes_overlap, pts_overlap, G_glob);
    
    % Remaining polygons are glued to multiple sub-polygons
    [poly, nodes_overlap, pts_overlap] = glueUpperPolygonMultiple(polys, poly, 7, 11, ...
                                                        nodes_overlap, pts_overlap, G_glob);
    
    [poly, nodes_overlap, pts_overlap] = glueUpperPolygonMultiple(polys, poly, 2, 7, ...
                                                            nodes_overlap, pts_overlap, G_glob);
    
    % Bottom polygon glued to structured polygon and fault
    [poly, nodes_overlap, pts_overlap, ...
        top_nodes, bottom_nodes, west_nodes] = gluePolygon1(polys, poly, 1, [3,2], ...
                                                       nodes_overlap, pts_overlap, G_glob, node_density);
    
    colors = [[0 0.4470 0.7410]; 
              [0.8500 0.3250 0.0980];
              [0.9290 0.6940 0.1250];
              [0.4940 0.1840 0.5560];
              [0.4660 0.6740 0.1880];
              [0.3010 0.7450 0.9330];
              [0.6350 0.0780 0.1840]];
    
    % Triangulation of Top Left Fault
    poly31_neighbors = cell(11, 2);
    % List in counterclockwise order, starting from top left
    poly31_neighbors{1,1} = poly.p32; poly31_neighbors{1,2} = 'top';
    poly31_neighbors{2,1} = poly.p28; poly31_neighbors{2,2} = 'west';
    poly31_neighbors{3,1} = poly.p20; poly31_neighbors{3,2} = 'west';
    poly31_neighbors{4,1} = poly.p15; poly31_neighbors{4,2} = 'west';
    poly31_neighbors{5,1} = poly.p6; poly31_neighbors{5,2} = 'west';
    poly31_neighbors{6,1} = poly.p17; poly31_neighbors{6,2} = 'west';
    poly31_neighbors{7,1} = poly.p11left; poly31_neighbors{7,2} = 'west';
    poly31_neighbors{8,1} = poly.p4; poly31_neighbors{8,2} = 'east';
    poly31_neighbors{9,1} = poly.p14; poly31_neighbors{9,2} = 'east';
    poly31_neighbors{10,1} = poly.p19A; poly31_neighbors{10,2} = 'east';
    poly31_neighbors{11,1} = poly.p29A; poly31_neighbors{11,2} = 'east';
    
    % Unstructured grid: quadrilaterals + triangles
    poly = Faults.makeUnstructuredGrid(polys, poly, 31, poly31_neighbors, ...
                                        2, Lx, Lz, Nx, Nz);
    
    [poly, p31At] = Faults.QuasiRandomPointDistribution(poly, "p31fAt", G_glob, node_density, false, colors);
    
    % Triangulation of Top Right Fault
    poly25_neighbors = cell(12, 2);
    % List in counterclockwise order, starting from top left
    poly25_neighbors{1,1} = poly.p32; poly25_neighbors{1,2} = 'top';
    poly25_neighbors{2,1} = poly.p29B; poly25_neighbors{2,2} = {'west', 'top'};
    poly25_neighbors{3,1} = poly.p29C; poly25_neighbors{3,2} = {'west', 'bottom'};
    poly25_neighbors{4,1} = poly.p19B; poly25_neighbors{4,2} = {'west', 'top'};
    poly25_neighbors{5,1} = poly.p19C; poly25_neighbors{5,2} = {'west', 'bottom'};
    poly25_neighbors{6,1} = poly.p14; poly25_neighbors{6,2} = 'west';
    poly25_neighbors{7,1} = poly.p4; poly25_neighbors{7,2} = 'west';
    poly25_neighbors{8,1} = poly.p11right; poly25_neighbors{8,2} = 'east';
    poly25_neighbors{9,1} = poly.p5A; poly25_neighbors{9,2} = 'east';
    poly25_neighbors{10,1} = poly.p13; poly25_neighbors{10,2} = 'east';
    poly25_neighbors{11,1} = poly.p18; poly25_neighbors{11,2} = 'east';
    poly25_neighbors{12,1} = poly.p30; poly25_neighbors{12,2} = 'east';
    
    poly = Faults.makeUnstructuredGrid(polys, poly, 25, poly25_neighbors, ...
                                        2, Lx, Lz, Nx, Nz);
    
    % Triangulate bottom part of fault and end-point of pinch-outs
    [poly, p25E] = Faults.QuasiRandomPointDistribution(poly, "p25fE", G_glob, node_density, false, colors);
    [poly, p25Ft] = Faults.QuasiRandomPointDistribution(poly, "p25fFt", G_glob, 2*node_density, false, colors);
    [poly, p25Gt] = Faults.QuasiRandomPointDistribution(poly, "p25fGt", G_glob, 2*node_density, false, colors);
    
    % Triangulation of Right Fault
    poly12_neighbors = cell(2, 2);
    poly12_neighbors{1,1} = poly.p5B; poly12_neighbors{1,2} = 'top';
    poly12_neighbors{2,1} = poly.p5C; poly12_neighbors{2,2} = 'bottom';
    
    poly = Faults.makeUnstructuredGrid(polys, poly, 12, poly12_neighbors, ...
                                        1.5, Lx, Lz, Nx, Nz);
    
    [poly, p12At] = Faults.QuasiRandomPointDistribution(poly, "p12fAt", G_glob, node_density, false, colors);
    
    % Triangulation of Bottom Fault
    polyBF_nums = [24, 9, 21, 26, 22, 23]; % polyBF = poly bottom fault
    
    polyBF_neighbors.p24 = cell(6,2);
    polyBF_neighbors.p9 = cell(1,2);
    polyBF_neighbors.p21 = cell(5,2);
    polyBF_neighbors.p26 = cell(2,2);
    polyBF_neighbors.p22 = cell(1,2);
    polyBF_neighbors.p23 = cell(3,2);
    % poly 24
    polyBF_neighbors.p24{1,1} = poly.p6; polyBF_neighbors.p24{1,2} = 'top';
    polyBF_neighbors.p24{2,1} = poly.p27; polyBF_neighbors.p24{2,2} = 'west';
    polyBF_neighbors.p24{3,1} = poly.p16; polyBF_neighbors.p24{3,2} = 'west';
    polyBF_neighbors.p24{4,1} = poly.p10; polyBF_neighbors.p24{4,2} = 'west';
    polyBF_neighbors.p24{5,1} = poly.p11left; polyBF_neighbors.p24{5,2} = 'east';
    polyBF_neighbors.p24{6,1} = poly.p17; polyBF_neighbors.p24{6,2} = 'east';
    % poly 9
    polyBF_neighbors.p9{1,1} = poly.p11left; polyBF_neighbors.p9{1,2} = 'east';
    % poly 21
    polyBF_neighbors.p21{1,1} = poly.p8; polyBF_neighbors.p21{1,2} = 'west';
    polyBF_neighbors.p21{2,1} = poly.p2left; polyBF_neighbors.p21{2,2} = 'east';
    polyBF_neighbors.p21{3,1} = poly.p7small; polyBF_neighbors.p21{3,2} = {'top', 'east', 'bottom'};
    polyBF_neighbors.p21{4,1} = poly.p7left; polyBF_neighbors.p21{4,2} = 'east';
    polyBF_neighbors.p21{5,1} = poly.p11left; polyBF_neighbors.p21{5,2} = 'east';
    % poly 26
    polyBF_neighbors.p26{1,1} = poly.p8; polyBF_neighbors.p26{1,2} = 'west';
    polyBF_neighbors.p26{2,1} = poly.p3; polyBF_neighbors.p26{2,2} = 'west';
    % poly 22
    polyBF_neighbors.p22{1,1} = poly.p2left; polyBF_neighbors.p22{1,2} = 'east';
    % poly 23
    polyBF_neighbors.p23{1,1} = poly.p3; polyBF_neighbors.p23{1,2} = 'west';
    polyBF_neighbors.p23{2,1} = poly.p1mid; polyBF_neighbors.p23{2,2} = 'bottom';
    polyBF_neighbors.p23{3,1} = poly.p2left; polyBF_neighbors.p23{3,2} = 'east';
    
    polyBF_norder = cell(17,3);
    for i=1:4
        polyBF_norder{i,1} = polyBF_neighbors.p24{i,1};
        polyBF_norder{i,2} = polyBF_neighbors.p24{i,2};
        polyBF_norder{i,3} = 'p24';
    end
    polyBF_norder{5,1} = polyBF_neighbors.p21{1,1}; 
    polyBF_norder{5,2} = polyBF_neighbors.p21{1,2};
    polyBF_norder{5,3} = 'p21';
    for i=6:7
        polyBF_norder{i,1} = polyBF_neighbors.p26{i-5,1};
        polyBF_norder{i,2} = polyBF_neighbors.p26{i-5,2};
        polyBF_norder{i,3} = 'p26';
    end
    for i=8:10
        polyBF_norder{i,1} = polyBF_neighbors.p23{i-7,1};
        polyBF_norder{i,2} = polyBF_neighbors.p23{i-7,2};
        polyBF_norder{i,3} = 'p23';
    end
    polyBF_norder{11,1} = polyBF_neighbors.p22{1,1}; 
    polyBF_norder{11,2} = polyBF_neighbors.p22{1,2};
    polyBF_norder{11,3} = 'p22';
    for i=12:15
        polyBF_norder{i,1} = polyBF_neighbors.p21{i-10,1}; 
        polyBF_norder{i,2} = polyBF_neighbors.p21{i-10,2};
        polyBF_norder{i,3} = 'p21';
    end
    polyBF_norder{16,1} = polyBF_neighbors.p9{1,1}; 
    polyBF_norder{16,2} = polyBF_neighbors.p9{1,2};
    polyBF_norder{16,3} = 'p9';
    for i=17:18
        polyBF_norder{i,1} = polyBF_neighbors.p24{i-12,1}; 
        polyBF_norder{i,2} = polyBF_neighbors.p24{i-12,2};
        polyBF_norder{i,3} = 'p24';
    end
    
    [poly, nodes_overlap] = triangulateBottomFault(polys, poly, polyBF_nums, polyBF_norder, ...
                                                       nodes_overlap, pts_overlap, G_glob, 2);
    
    % Triangulation with added internal points (for internal faults)
    [poly, nodes_overlap] = triangulateInternalFaults(poly, 24, ...
                                                     nodes_overlap, pts_overlap, G_glob);
       
    [poly, nodes_overlap] = triangulateInternalFaults(poly, 9, ...
                                                      nodes_overlap, pts_overlap, G_glob);
     
    [poly, nodes_overlap] = triangulateInternalFaults(poly, 21, ...
                                                       nodes_overlap, pts_overlap, G_glob);
    
    [poly, nodes_overlap] = triangulateInternalFaults(poly, 26, ...
                                                        nodes_overlap, pts_overlap, G_glob);
    
    [poly, nodes_overlap] = triangulateInternalFaults(poly, 22, ...
                                                        nodes_overlap, pts_overlap, G_glob);
    
    [poly, nodes_overlap] = triangulateInternalFaults(poly, 23, ...
                                                        nodes_overlap, pts_overlap, G_glob);
    
    % Triangulate internal parts separately
    bf_polys = [26,22]; % other polygons are cartesian quadrilaterals
    
    % Triangulate irregular twin polygons
    [poly, p26_22] = Faults.QuasiRandomPointDistribution(poly, bf_polys, G_glob, node_density, false, colors);
    % Quadrilaterate the more regular polygons
    poly = Faults.heterogeneousFault(polys, poly, 1.5, Lx, Lz, Nx, Nz);
    % Triangulate bottom-most part
    [poly, p23B] = Faults.QuasiRandomPointDistribution(poly, "p23fB", G_glob, node_density, false, colors);
    
    % Glue-preparation
    % Remove all PEBI-polygons to check if triangulation causes problems
                 
    poly_idxs = {poly.p31fAq.p_idx; poly.p31fAt.p_idx; ...
                 poly.p25fA.p_idx; poly.p25fB.p_idx; poly.p25fC.p_idx; ...             
                 poly.p29A.p_idx; poly.p29B.p_idx; poly.p25fFq.p_idx; ...
                 poly.p25fFt.p_idx; poly.p29C.p_idx; poly.p19A.p_idx; ...
                 poly.p19B.p_idx; poly.p25fGq.p_idx; poly.p25fGt.p_idx; ...
                 poly.p25fD.p_idx; poly.p25fE.p_idx; poly.p28.p_idx; ...
                 poly.p20.p_idx; poly.p15.p_idx; poly.p6.p_idx; ...
                 poly.p19C.p_idx; poly.p14.p_idx; poly.p4.p_idx; ...
                 poly.p30.p_idx; poly.p18.p_idx; poly.p13.p_idx; ...
                 poly.p5A.p_idx; poly.p5B.p_idx; poly.p12fAq.p_idx; ...
                 poly.p12fAt.p_idx; poly.p5C.p_idx; poly.p27.p_idx; ...
                 poly.p17.p_idx; poly.p11left.p_idx; poly.p11mid.p_idx; ...
                 poly.p11right.p_idx; poly.p16.p_idx; poly.p10.p_idx; ...
                 poly.p8.p_idx; poly.p3.p_idx; poly.p7left.p_idx; ...
                 poly.p7mid.p_idx; poly.p7right.p_idx; poly.p7small.p_idx; ...
                 poly.p2left.p_idx; poly.p2mid.p_idx; poly.p2right.p_idx; ...
                 poly.p24fA.p_idx; poly.p24fB.p_idx; poly.p24fC.p_idx; ...
                 poly.p9fA.p_idx; poly.p21fA.p_idx; poly.p21fB.p_idx; ...
                 poly.p21fC.p_idx; poly.p21fD.p_idx; poly.p22f.p_idx; ...
                 poly.p26f.p_idx; poly.p23fA.p_idx; poly.p23fB.p_idx; ...
                 poly.p1left.p_idx; poly.p1mid.p_idx; poly.p1rightA.p_idx; ...
                 poly.p1rightB.p_idx; poly.p1rightC.p_idx; poly.p1small.p_idx};
                 
    
    % Glue together subgrids
    poly.glued = poly.p32; % top grid is basis for gluing
    poly.glued.G.facies = repmat(poly.glued.facies, poly.glued.G.cells.num, 1);
    poly.glued.cell_range.p32 = [1, poly.p32.G.cells.num];
    
    for i=1:numel(poly_idxs)    
        px = poly_idxs{i};
        if verbose
            disp(px)
        end
        G_sub = poly.(px).G; 
        G_glued = glue2DGrid_FF(poly.glued.G, G_sub, 'poly_idx', px);    
    
        new_cells = G_sub.cells.indexMap + poly.glued.G.cells.num;
        poly.glued.cell_range.(px) = [poly.glued.G.cells.num+1, poly.glued.G.cells.num+max(G_sub.cells.indexMap)];
    
        G_glued.cells.indexMap = [poly.glued.G.cells.indexMap; new_cells];
        G_glued.facies = [poly.glued.G.facies; repmat(poly.(px).facies, G_sub.cells.num, 1)];
        G_glued.i = [poly.glued.G.i; G_sub.i];
        G_glued.j = [poly.glued.G.j; G_sub.j];
    
        poly.glued.G = G_glued;  
    end
    
    poly.glued.G = computeGeometry(poly.glued.G);
    
    if plotUnstructured
        figure(4)
        plotGrid(poly.glued.G)
        plotCellData(poly.glued.G, double(isnan(poly.glued.G.i)))
        title('Unstructured cells')
    end
    
    % Remove impermeable layers from glued grid
    Gg = poly.glued.G;
    poly.sim = poly.glued;
    [G_sim, gc, gf] = extractSubgrid(poly.glued.G, poly.glued.G.facies ~= 7);
    % G_sim.cells.indexMap equals gc
    G_sim.i = Gg.i(gc);
    G_sim.j = Gg.j(gc);
    G_sim.facies = Gg.facies(gc);
    poly.sim.G = G_sim;
    
    for i=1:numel(poly_idxs)    
        px = poly_idxs{i};
        G_sub = poly.(px).G; 
        pg = poly.glued;
        if all(pg.G.facies(pg.cell_range.(px)) == 7) % facie 7 (impermeable) not included in simulation-grid
            poly.sim.cell_range = rmfield(poly.sim.cell_range, px);
        else
            poly.sim.cell_range.(px) = find(ismember(gc, pg.cell_range.(px)));
        end
    end
    
    Gg = poly.sim.G; % THIS IS THE COMPLETE GLUED GRID
    %---------
    %KH:
    G = Gg;
    G.cells.tag = G.facies;

    % Try to fix mistakes
    G = uniqueifyNodes(G);
    G = removeCollapsedFaces(G);
    G = computeGeometry(G);
    G = makeLayeredGrid(G, 0.01);
    G = computeGeometry(G);
    G = removePinch(G);
    G = computeGeometry(G);
    ok = checkGrid(G);
    assert(ok, 'Grid not ok');

    if opt.savegrid
        save(savepath, 'G');
        disp(['Saved grid to ', savepath, '.'])
    end
end

function G = uniqueifyNodes(G, varargin)
    opt = struct('tol', 1e-12);
    opt = merge_options(opt, varargin{:});
    tol = opt.tol;

    % Uniquify nodes
    [G.nodes.coords, i, j] = unique(G.nodes.coords, 'rows');
    
    % Map face nodes
    G.faces.nodes    = j(G.faces.nodes);
    
    % Remove nodes with small difference
    if tol>0
      d = [inf; sqrt(sum(diff(G.nodes.coords,1) .^ 2, 2))];
      I = d < tol;
      G.nodes.coords = G.nodes.coords(~I,:);
      J = ones(size(I));
      J(I) = 0;  J = cumsum(J);
      G.faces.nodes = J(G.faces.nodes);
    end
    G.nodes.num = size(G.nodes.coords, 1);
end

function G = removeCollapsedFaces(G)
    % Identify faces with the same start and end node
    nodeStart = G.faces.nodes(G.faces.nodePos(1:end-1));
    nodeEnd = G.faces.nodes(G.faces.nodePos(2:end) - 1);
    selfLoopingLog = nodeStart == nodeEnd;
    cs_selfLoopingLog = cumsum(selfLoopingLog);
    oldToNewFaces = (1:G.faces.num)' - cs_selfLoopingLog;
    newToOldFaces = find(~selfLoopingLog);
    selfLooping = find(selfLoopingLog);

    newNumFaces = G.faces.num - numel(selfLooping);
    G.faces.num = newNumFaces;
    G.faces.nodes([G.faces.nodePos(selfLooping); G.faces.nodePos(selfLooping+1)-1]) = [];
    cs_facesToBeDeleted = cumsum(diff(G.faces.nodePos).*selfLoopingLog);
    G.faces.nodePos(1:end-1) = G.faces.nodePos(1:end-1) - cs_facesToBeDeleted;
    G.faces.nodePos(end) = G.faces.nodePos(end) - cs_facesToBeDeleted(end);
    G.faces.nodePos(selfLooping) = [];
    G.faces.areas = G.faces.areas(newToOldFaces);
    G.faces.neighbors = G.faces.neighbors(newToOldFaces, :);
    G.faces.centroids = G.faces.centroids(newToOldFaces);
    G.faces.normals = G.faces.normals(newToOldFaces, :);
    G.faces.global = G.faces.global(newToOldFaces); %not sure what this is, but change it anyways


    % Initialize new facePos
    newFacePos = zeros(G.cells.num + 1, 1);
    newFacePos(1) = 1;
    
    % Update face numbering in cells
    newFaces = [];
    for i = 1:G.cells.num
        faceIDs = G.cells.faces(G.cells.facePos(i):G.cells.facePos(i+1)-1);
        newFaceIDs = setdiff(faceIDs, selfLooping);
        
        newFaces = [newFaces; oldToNewFaces(newFaceIDs)];
        newFacePos(i + 1) = newFacePos(i) + numel(newFaceIDs);
    end
    G.cells.faces = newFaces;
    G.cells.facePos = newFacePos;
end
