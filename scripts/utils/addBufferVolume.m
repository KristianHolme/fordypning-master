function G = addBufferVolume(G, rock, varargin)
    % adds buffervolume on left and right boundary of G
    % need to have G.tag to indicate facies

    opt = struct('eps', 1e-10, 'slice', true, 'verbose', false);
    opt = merge_options(opt, varargin{:});

    if ~isfield(G.cells, 'tag')
        G.cells.tag = rock.regions.saturation;
    end
    % if opt.slice
    %     dispif(opt.verbose, "Slicing to add buffervolume...\n")
    %     G = sliceGrid(G, [0.5, 0.5, -1; 0.5, 0.5, 1201], 'cutDir', [0 1 0]);
    %     % G = sliceGrid(G, {[0.5, 0.5, -1], [8399.5, 0.5, 1201]}, 'normal', {[1, 0, 0], [1, 0, 0]});
    %     dispif(opt.verbose, "Done slicing.\n")
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
                G.cells.volumes(cell) = G.cells.volumes(cell) + extraVolume;
            end
        end
    end
end