function G = addBufferVolumeToGridOnly(G, varargin)
    % adds buffervolume on left and right boundary of G
    % need to have G.tag to indicate facies

    opt = struct('eps', 1, ...
        'verbose', false, ...
        'slice', false,...%slice not used
        'hasCorrectBufferVolumes', false);
    opt = merge_options(opt, varargin{:});

    assert(isfield(G.cells, 'tag'), "No tag on G.cells!")
    eps = opt.eps;
    areaVolumeConstant = 5e4;
    
    if ~opt.hasCorrectBufferVolumes
        G = getBufferCells(G);
    end
    bufferMult = ones(numel(G.bufferCells),1);
    disp('Adding multiplier, leaving rock normal')

    multiplier = 1 + areaVolumeConstant/eps; %opt 3

    for ic = 1:numel(G.bufferCells)
        cell = G.bufferCells(ic);
        facies = G.cells.tag(cell);
        if ismember(facies, [2, 3, 4, 5])
            G.bufferCells(end+1) = cell;           
            bufferMult(ic) = multiplier;
        end
    end
    G.bufferMult = bufferMult;
end