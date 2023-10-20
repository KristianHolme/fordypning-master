function fluid = setupFluid11A(simcase, varargin)
    opt = struct('deck', []);
    opt = merge_options(opt, varargin{:});

    
    faciesSwimm     = [0.32; 0.14; 0.12; 0.12; 0.12; 0.10; NaN];
    faciesPentry    = [1500; 300; 100; 25; 10; 1;NaN]*Pascal;
    faciesDw        = [1;1;1;1;1;1;1]*1e-9; %m^2s^-1
    faciesDg        = [1;1;1;1;1;1;1]*1.6e-5; %m^2s^-1

    fluidcase = simcase.fluidcase;
    if strcmp(fluidcase, 'simple')
        fluid = initSimpleADIFluid('phases', 'WG', ...
                               'mu', [1.00159244418e-03, 1.46758344866e-05]*Pascal*second, ...
                               'rho', [9.98212651296e+02, 2.05864576494e+00]*kilogram*meter^-3, ...
                               'n', [2,2], ...
                               'c', [1e-7/barsa, 1e-4/barsa]);
    elseif strcmp(fluidcase, 'experimental')
        %currently three phases to check if ntpfa is happy
        fluid = initSimpleADIFluid('phases', 'WOG', ...
                               'mu', [1.00159244418e-03, 1.00159244418e-03, 1.46758344866e-05]*Pascal*second, ...
                               'rho', [9.98212651296e+02, 9.98212651296e+02, 2.05864576494e+00]*kilogram*meter^-3, ...
                               'n', [2, 2,2], ...
                               'c', [1e-7/barsa, 1e-7/barsa, 1e-4/barsa]);
    else
        fluid = initDeckADIFluid(simcase.deck);
    end
    % fluid.rhoGS = rhoGS;
    
end