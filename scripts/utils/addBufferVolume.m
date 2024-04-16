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

    % multiplier = 1 + extraVolume; %opt 1
    % multiplier = 1 + extraVolume/rock.poro(cell); %opt 2
    multiplier = 1 + areaVolumeConstant/eps; %opt 3

    for ic = 1:numel(G.bufferCells)
        cell = G.bufferCells(ic);
        % cell = max(G.faces.neighbors(face, :));
        facies = G.cells.tag(cell);
        % assert(facies ~=6 );
        % face = G.bufferFaces(ic);
        % faceArea = G.faces.areas(face);
        if ismember(facies, [2, 3, 4, 5])
            G.bufferCells(end+1) = cell;
            % extraVolume = faceArea*areaVolumeConstant/eps;
            % multiplier = (areaVolumeConstant/eps)/rock.poro(cell);
           
            bufferMult(ic) = multiplier;

            if opt.bufferMult
                opt.adjustPoro = false;
                % bufferMult(ic) = 1 + extraVolume; %opt 1
                % bufferMult(ic) = 1 + extraVolume/rock.poro(cell); %opt 2
                % bufferMult(ic) = 1 + areaVolumeConstant/eps; %opt 3
                bufferMult(ic) = multiplier;
                

            elseif opt.adjustPoro
                % rock.poro(cell) = rock.poro(cell) + extraVolume;
                rock.poro(cell) = rock.poro(cell)*multiplier;
                % rock.poro(cell) = multiplier; %almost as in pyopmspe11
            else
                G.cells.volumes(cell) = G.cells.volumes(cell)*multiplier;
            end
        end
    end
    if opt.bufferMult
        rock.bufferMult = bufferMult;
    end
end