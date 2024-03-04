function [G, rock] = addBufferVolume(G, rock, varargin)
    % adds buffervolume on left and right boundary of G
    % need to have G.tag to indicate facies

    opt = struct('eps', 1, ...
        'verbose', false, ...
        'slice', false,...%slice not used
        'adjustPoro', true, ...
        'bufferMult', false);
    opt = merge_options(opt, varargin{:});

    assert(isfield(G.cells, 'tag'), "No tag on G.cells!")
    % if ~isfield(G.cells, 'tag')
    %     G.cells.tag = rock.regions.saturation;
    % end
    

    % bf = boundaryFaces(G);
    
    % tol = 1e-10;
    eps = opt.eps;
    % xlimit = 8400;
    areaVolumeConstant = 5e4;

    G = getBufferCells(G);
    % G.bufferCells = [];
    bufferMult = ones(numel(G.bufferCells),1);
    if opt.bufferMult
        disp('Adding multiplier, leaving rock normal')
    end

    for ic = 1:numel(G.bufferCells)
        cell = G.bufferCells(ic);
        % cell = max(G.faces.neighbors(face, :));
        facies = G.cells.tag(cell);
        assert(facies ~=6 );
        face = G.bufferFaces(ic);
        faceArea = G.faces.areas(face);
        if ismember(facies, [2, 3, 4, 5])
            G.bufferCells(end+1) = cell;
            extraVolume = faceArea*areaVolumeConstant/eps;

            if opt.bufferMult
                opt.adjustPoro = false;
                bufferMult(ic) = 1 + extraVolume/rock.poro(cell);
            elseif opt.adjustPoro
                rock.poro(cell) = rock.poro(cell) + extraVolume;
            else
                G.cells.volumes(cell) = G.cells.volumes(cell)*(1 + extraVolume/rock.poro(cell));%the specified volume is pore volume?
            end
        end
    end
    rock.bufferMult = bufferMult;
end