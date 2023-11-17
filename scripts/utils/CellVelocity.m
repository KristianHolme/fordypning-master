function cv = CellVelocity(states, step, G, phase, direction)
    switch phase
        case 'w'
            phase = 1;
        case 'g'
            phase = 2;
    end
    
    cv = faceFlux2cellVelocity(G, states{step}.flux(:, phase));
    if nargin < 5
        cv = vecnorm(cv, 2, 2);
    else
        cv = cv(:, direction);
    end
end