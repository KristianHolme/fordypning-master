function G = addBufferVolume(G, rock, varargin)
    % adds buffervolume on left and right boundary of G
    % need to have G.tag to indicate facies

    opt = struct('eps', 1, ...
        'verbose', false, ...
        'slice', false);%slice not used
    opt = merge_options(opt, varargin{:});

    assert(isfield(G.cells, 'tag'), "No tag on G.cells!")
    % if ~isfield(G.cells, 'tag')
    %     G.cells.tag = rock.regions.saturation;
    % end
    

    bf = boundaryFaces(G);
    
    tol = 1e-10;
    eps = opt.eps;
    xlimit = 8400;
    areaVolumeConstant = 5e4;

    for iface = 1:numel(bf)
        face = bf(iface);
        faceArea = G.faces.areas(face);
        if (abs(G.faces.centroids(face, 1)) < tol) || (abs(G.faces.centroids(face, 1) - xlimit) < tol)
            cell = max(G.faces.neighbors(face, :));
            facies = G.cells.tag(cell);
            assert(facies ~=6 )
            if ismember(facies, [2, 3, 4, 5])
                extraVolume = faceArea*areaVolumeConstant/eps;
                oldVolume = G.cells.volumes(cell);
                G.cells.volumes(cell) = G.cells.volumes(cell)*(1 + extraVolume/rock.poro(cell));%the specified volume is pore volume?
            end
        end
    end
end