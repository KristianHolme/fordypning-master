function tbls = setupTables(G, varargin)
    
    opt = struct('dovirtual', false);
    opt = merge_options(opt, varargin{:});
    dovirtual = opt.dovirtual;
    
    nc = G.cells.num;
    nf = G.faces.num;
    nn = G.nodes.num;
    
    cellfacetbl.cells = rldecode((1 : nc)', diff(G.cells.facePos));
    cellfacetbl.faces = G.cells.faces(:, 1);
    cellfacetbl = IndexArray(cellfacetbl);

    cell_in_cellface = cellfacetbl.get('cells');
    face_in_cellface = cellfacetbl.get('faces');

    facenodetbl.faces = rldecode((1 : nf)', diff(G.faces.nodePos));
    facenodetbl.nodes = G.faces.nodes(:, 1);
    facenodetbl = IndexArray(facenodetbl);
    
    d = G.griddim;
    
    vecttbl.vect = (1 : d)';
    vecttbl = IndexArray(vecttbl);
    
    vect12tbl = crossIndexArray(vecttbl, vecttbl, {}, 'crossextend', {{'vect', {'vect1', 'vect2'}}});

    if dovirtual
        cellfacevecttbl = crossIndexArray(cellfacetbl, vecttbl, {}, 'virtual', true);
    else
        cellfacevecttbl = crossIndexArray(cellfacetbl, vecttbl, {}, 'optpureproduct', true);
    end

    celltbl.cells = (1 : nc)';
    celltbl = IndexArray(celltbl);

    facetbl.faces = (1 : nf)';
    facetbl = IndexArray(facetbl);

    nodetbl.nodes = (1 : nn)';
    nodetbl = IndexArray(nodetbl);
    
    N = G.faces.neighbors;
    intInx = all(N ~= 0, 2);
    intfacetbl.faces = find(intInx);
    intfacetbl = IndexArray(intfacetbl);
    
    if dovirtual
        cellvecttbl = crossIndexArray(celltbl, vecttbl, {}, 'virtual', true);
        facevecttbl = crossIndexArray(facetbl, vecttbl, {}, 'virtual', true);
    else
        cellvecttbl = crossIndexArray(celltbl, vecttbl, {}, 'optpureproduct', true);
        facevecttbl = crossIndexArray(facetbl, vecttbl, {}, 'optpureproduct', true);
    end
    
    gen = CrossIndexArrayGenerator;
    gen.tbl1 = cellvecttbl;
    gen.tbl2 = vecttbl;
    gen.replacefds1 = {{'vect', 'vect1'}};
    gen.replacefds2 = {{'vect', 'vect2'}};
    cellvect12tbl = gen.eval();
    cellvect12tbl = sortIndexArray(cellvect12tbl, {'cells', 'vect1', 'vect2'});
    
    gen = CrossIndexArrayGenerator;
    gen.tbl1 = cellfacetbl;
    gen.tbl2 = cellfacetbl;
    gen.replacefds1 = {{'faces', 'faces1'}};
    gen.replacefds2 = {{'faces', 'faces2'}};
    gen.mergefds = {'cells'};
    cellface12tbl = gen.eval();
    cellface12tbl = sortIndexArray(cellface12tbl, {'cells', 'faces1', 'faces2'});
    
    tbls = struct('celltbl'         , celltbl         , ...
                  'facetbl'         , facetbl         , ...
                  'nodetbl'         , nodetbl         , ...
                  'intfacetbl'      , intfacetbl      , ...
                  'vecttbl'         , vecttbl         , ...
                  'vect12tbl'       , vect12tbl       , ...
                  'cellvecttbl'     , cellvecttbl     , ...
                  'facevecttbl'     , facevecttbl     , ...
                  'cellfacetbl'     , cellfacetbl     , ...
                  'facenodetbl'     , facenodetbl     , ...
                  'cellface12tbl'   , cellface12tbl   , ...
                  'cellvect12tbl'   , cellvect12tbl   , ...
                  'cellfacevecttbl' , cellfacevecttbl , ...
                  'cell_in_cellface', cell_in_cellface, ...
                  'face_in_cellface', face_in_cellface);
end

