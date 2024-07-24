function G = generateStructuredGrid(nx, ny, nz, varargin)
%makes a cartesian grid for SPE11C.
%adds small buffer cells on front, right, back, left sides
opt = struct('save', true);
opt = merge_options(opt, varargin{:});
G = cartGrid([nx, 1, nz], [8400, 1, 1200]);
G = mcomputeGeometry(G);
geoData = readGeo('', 'assignExtra', true);
geoData = stretchGeo(rotateGrid(geoData));
G = tagbyFacies(G, geoData, 'vertIx', 3);
G = bufferSlice(G, 'C');
G = removeLayeredGrid(G);
layerthicknesses = [1; repmat(4998/ny, ny, 1); 1];%one meter thickness for buffer volume in front and back
G = makeLayeredGrid(G, layerthicknesses);
G = mcomputeGeometry(G);
G = rotateGrid(G);
G = mcomputeGeometry(G);

G = tagbyFacies(G, geoData, 'vertIx', 3);
G.nodes.coords = bendSPE11C(G.nodes.coords);
G = mcomputeGeometry(G);
G = getBufferCells(G);

G = addBoxWeights(G, 'SPEcase', 'C');
[w1, w2] = getinjcells(G, 'C');
G.cells.wellCells = {w1, w2};
G.faces.tag = zeros(G.faces.num, 1);

if opt.save
    filename = sprintf('spe11c_struct%dx%dx%d_grid.mat', nx, ny, nz);
    folder = 'grid-files';
    savepath = fullfile(folder, filename);
    fprintf('Saving to %s\n', savepath);
    save(savepath, "G");
end
end