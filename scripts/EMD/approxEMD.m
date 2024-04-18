function energy = approxEMD(w0, w1, varargin)
%does all setup and calculationfor earth movers distance OT approximation, and return
%energy
opt = struct('verbose', true, ...
    'tol', 1e-5, ...
    'L', 7, ...
    'nx', 840, ...
    'ny', 120);
opt = merge_options(opt, varargin{:});

w0 = flip(reshape(w0, opt.nx, opt.ny)');
w1 = flip(reshape(w1, opt.nx, opt.ny)');
% w1 = w1(:,1:120);
% w2 = w2(:,1:120);

p = 2; %p means the "groud metric" in the paper. 
% p = 1,2 or 3. p=3 means p=inf
% h = 10;

[h, rho0, rho1, ~, ~] = prepOT(w0, w1);

% calculation
tic();
[m,~,~] = W1PDHG_ML(h, rho0, rho1, p, opt);

t = toc();
dispif(opt.verbose, 'Elapsed time is %f seconds.\n', t);

%energy
energy = PrimalFunL2(m, h);
dispif(opt.verbose, 'energy:%f\n',energy);
end