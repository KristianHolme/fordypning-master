function [err, errvect, fwerr] = computeOrthError(G, rock, tbls, varargin)

% Compute orthorgonality error indicator |Kn| sin \theta.
% Options: if Knorm=true: normalize over |K|, i.e. |Kn|/|K| sin \theta
%          if noK=true: set K=1
% err     : For each cell the error at each face is summed up
% errvect : error vector at each cell-face
% fwerr   : For each cell the error at each face divided by face area is summed up

    opt = struct('Knorm', false, ...
                 'noK', false);
    opt = merge_options(opt, varargin{:});

    nc = G.cells.num;

    celltbl = tbls.celltbl;
    facetbl = tbls.facetbl;
    vecttbl = tbls.vecttbl;
    cellvecttbl = tbls.cellvecttbl;
    facevecttbl = tbls.facevecttbl;
    cellfacetbl = tbls.cellfacetbl;
    cellface12tbl = tbls.cellface12tbl;
    cellfacevecttbl = tbls.cellfacevecttbl;
    cell_in_cellface = tbls.cell_in_cellface;
    face_in_cellface = tbls.face_in_cellface;

    ndim = G.griddim;

    if opt.Knorm
        rock.perm = rock.perm ./ vecnorm(rock.perm, 2, 2);
    end

    if opt.noK
        rock.perm = ones(G.cells.num, ndim);
    end

    % % we only handle diagonal perm (otherwise we have to invert K for all cells)
    % if size(rock.perm, 2) == 1
    %     rock.perm = rldecode(rock.perm, ndim);
    % else
    %     assert(size(rock.perm, 2) == ndim, 'For the moment only diagonal perm')
    %     rock.perm = reshape(rock.perm', [], 1);
    % end

    vect12tbl = crossIndexArray(vecttbl, vecttbl, {}, 'crossextend', {{'vect', {'vect1', 'vect2'}}});
    cellfacevect12tbl = crossIndexArray(cellfacevecttbl, cellfacevecttbl, {'cells', 'faces'}, 'crossextend', {{'vect', {'vect1', 'vect2'}}});
    cellfacevect12tbl = sortIndexArray(cellfacevect12tbl, {'cells', 'faces', 'vect1', 'vect2'});

    [cvec, normals, Kn] = setupGeometryVectors(G, rock, tbls);

    % We have to be careful: The cell-face order is not the same in cellfacetbl and cellfacevect12tbl

    sorted_cellfacetbl = sortIndexArray(cellfacetbl, {'cells', 'faces'});
    map = TensorMap();
    map.fromTbl = sorted_cellfacetbl;
    map.toTbl = cellfacetbl;
    map.mergefds = {'cells', 'faces'};
    inds = map.getDispatchInd();

    cvecmat = reshape(cvec, ndim, [])';

    Amat = zeros(cellfacetbl.num, ndim*ndim);

    for icf = 1 : cellfacetbl.num
        c = cvecmat(icf, :)';
        c = c./norm(c);
        D = null(c');
        D = reshape(D, [], 1);
        Amat(inds(icf),  :) = [c; D]';
    end

    % Matrix transformation from cell-face coordinate system (c, d1, d2) to global (x,y,z)
    At = reshape(Amat', [], 1);
    % A is in celfacevect12tbl

    % we multiply Kn with At at each cell face
    prod = TensorProd();
    prod.tbl1 = cellfacevect12tbl;
    prod.tbl2 = cellfacevecttbl;
    prod.tbl3 = cellfacevecttbl;
    prod.replacefds1 = {{'vect2', 'vectred'}, {'vect1', 'vect'}};
    prod.replacefds2 = {{'vect', 'vectred'}};
    prod.mergefds = {'cells', 'faces'};
    prod.reducefds = {'vectred'};
    prod = prod.setup();
    At_prod = prod; % we reuse it later

    AtKn = prod.eval(At, Kn);

    % We take the last components (they correspond to the orthogonal space of cvec)
    I = ones(ndim, 1);
    I(1) = 0;
    I = repmat(I, cellfacetbl.num, 1);

    IAtKn = I.*AtKn;

    % We multiply with A
    prod = TensorProd();
    prod.tbl1 = cellfacevect12tbl;
    prod.tbl2 = cellfacevecttbl;
    prod.tbl3 = cellfacevecttbl;
    prod.replacefds1 = {{'vect2', 'vect'}};
    prod.replacefds2 = {{'vect', 'vect1'}};
    prod.mergefds = {'cells', 'faces'};
    prod.reducefds = {'vect1'};
    prod = prod.setup();

    AIAtKn = prod.eval(At, IAtKn);
    errvect = AIAtKn;

    % We compute the norm (per cellface)
    AIAtKnSq = AIAtKn.^2;

    map = TensorMap();
    map.fromTbl = cellfacevecttbl;
    map.toTbl = cellfacetbl;
    map.mergefds = {'cells', 'faces'};
    map = map.setup();

    AIAtKnSq = map.eval(AIAtKnSq);
    normAIAtKn = sqrt(AIAtKnSq);

    % We collect the result per cells

    map = TensorMap();
    map.fromTbl = cellfacetbl;
    map.toTbl = celltbl;
    map.mergefds = {'cells'};
    map = map.setup();

    err = map.eval(normAIAtKn);

    if nargout > 2
        % We weight with face area
        prod = TensorProd();
        prod.tbl1 = cellfacetbl;
        prod.tbl2 = facetbl;
        prod.tbl3 = celltbl;
        prod.reducefds = {'faces'};
        prod = prod.setup();

        farea = G.faces.areas;
        fwerr = prod.eval(normAIAtKn, 1./farea);
    end

end