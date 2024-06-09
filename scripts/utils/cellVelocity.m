function cv = cellVelocity(states, step, G, phase, varargin)
    opt = struct('direction', []);
    opt = merge_options(opt, varargin{:});
    switch phase
        case 'w'
            phase = 1;
        case 'g'
            phase = 2;
    end
    
    cv = faceFlux2cellVelocity(G, states{step}.flux(:, phase));
    if isempty(opt.direction)
        cv = vecnorm(cv, 2, 2);
    else
        assert(isnumeric(opt.direction))
        cv = cv(:, opt.direction);
    end
end