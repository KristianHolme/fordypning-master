function [cvec, normals, Kn] = setupGeometryVectors(G, rock, tbls, varargin)
% cvec, normals and Kn  are in cellfacevecttbl
    
    opt = struct('dooptimize', false);
    opt = merge_options(opt, varargin{:});
    
    dooptimize = opt.dooptimize;

    nc = G.cells.num;
    
    celltbl = tbls.celltbl;
    facetbl = tbls.facetbl;
    vecttbl = tbls.vecttbl;
    cellvecttbl = tbls.cellvecttbl;
    facevecttbl = tbls.facevecttbl;
    cellfacetbl = tbls.cellfacetbl;
    cellvect12tbl = tbls.cellvect12tbl;
    cellface12tbl = tbls.cellface12tbl;
    cellfacevecttbl = tbls.cellfacevecttbl;
    cell_in_cellface = tbls.cell_in_cellface;
    face_in_cellface = tbls.face_in_cellface;
    
    perm = permTensor(rock, G.griddim);
    perm = reshape(perm', [], 1);
    
    normals = G.faces.normals;
    normals = reshape(normals', [], 1);
    cn = cellfacetbl.get('cells');
    cf = cellfacetbl.get('faces');
    sgn = 2*double(G.faces.neighbors(cf, 1) == cn) - 1;
    
    prod = TensorProd();
    prod.tbl1 = facevecttbl;
    prod.tbl2 = cellfacetbl;
    prod.tbl3 = cellfacevecttbl;
    prod.mergefds = {'faces'};
    prod = prod.setup();
    
    normals = prod.eval(normals, sgn);
    
    prod = TensorProd();
    prod.tbl1 = cellvect12tbl;
    prod.tbl2 = cellfacevecttbl;
    prod.tbl3 = cellfacevecttbl;
    prod.replacefds1 = {{'vect1', 'vect'}};
    prod.replacefds2 = {{'vect', 'vect2'}};
    prod.mergefds = {'cells'};
    prod.reducefds = {'vect2'};
    prod = prod.setup();
    
    Kn = prod.eval(perm, normals);
    
    xc = G.cells.centroids;
    xc = reshape(xc', [], 1);
    xf = G.faces.centroids;
    xf = reshape(xf', [], 1);

    map = TensorMap();
    map.fromTbl = cellvecttbl;
    map.toTbl = cellfacevecttbl;
    map.mergefds = {'cells', 'vect'};
    
    cfn = cellfacetbl.num;
    cn = celltbl.num;
    fn = facetbl.num;
    d = G.griddim;
    
    if ~dooptimize
        map = map.setup();
    else
        map.pivottbl = cellfacevecttbl;
        d = G.griddim;
        [v, cf] = ind2sub([d, cfn], (1 : map.pivottbl.num)');
        map.dispind1 = sub2ind([d, cn], v, cell_in_cellface(cf));
        map.dispind2 = (1 : map.pivottbl.num)';
        map.issetup = true;
    end

    xc = map.eval(xc);

    map = TensorMap();
    map.fromTbl = facevecttbl;
    map.toTbl = cellfacevecttbl;
    map.mergefds = {'faces', 'vect'};
    
    if ~dooptimize
        map = map.setup();
    else
        map.pivottbl = cellfacevecttbl;
        [v, cf] = ind2sub([d, cfn], (1 : map.pivottbl.num)');
        map.dispind1 = sub2ind([d, fn], v, face_in_cellface(cf));
        map.dispind2 = (1 : map.pivottbl.num)';
        map.issetup = true;
    end
    
    xf = map.eval(xf);

    cvec = xf - xc;

end

