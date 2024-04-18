f1 = [[100, 40, 22]; [211, 20, 2]; [32, 190, 150]; [2, 100, 100]];
f2 = [[0, 0, 0]; [50, 100, 80]; [255, 255, 255]];
w1 = [0.4; 0.3; 0.2; 0.1];
w2 = [0.5; 0.3; 0.2];

f1 = [100, 40, 22, 2];
f2 = [80, 1, 30];


G1 = data{1}.G;
G2 = data{2}.G;
nc1 = G1.cells.num;
nc2 = G2.cells.num;
w1 = data{1}.statedata;
w2 = data{2}.statedata;
f1 = G1.cells.centroids;
f2 = G2.cells.centroids;
dist = G1.cells.centroids*G2.cells.centroids';
%%
import clib.opencv.*
%%
n1 = 100;
n2 = 520;
w1 = rand(n1, 1);
w2 = rand(n2,1);
f1 = rand(n1, 3);
f2 = rand(n2, 3);
dist = f1*f2';

% opts = optimoptions('linprog', 'UseParallel',true);
opts = optimoptions('linprog');
opts.MaxTime = 100;

tic();
[x, fval] = emd(f1, f2, w1, w2, dist, opts);fval
toc()

% cost = ones
tic()
flow = clib.opencv.cv.wrapperEMD([w1,f1], [w2,f2], clib.opencv.cv.DistanceTypes.DIST_L1)
toc()

%%
% nx = 100;
% ny = 200;
% w1 = rand(nx, ny);
% w2 = rand(nx,ny);
orgx = linspace(0,8400, 840);
orgy = linspace(0,1200, 120);
nx = 840;
ny = 120;
w1 = flip(reshape(data{1,1}.statedata, nx, ny)');
w2 = flip(reshape(data{2,2}.statedata, nx, ny)');
% w1 = w1(:,1:120);
% w2 = w2(:,1:120);

p = 2; %p means the "groud metric" in the paper. 
% p = 1,2 or 3. p=3 means p=inf
% h = 10;

[h, rho0, rho1, x, y] = prepOT(w1, w2);
%% algorthim parameters
opts = [];
opts.tol = 1e-5; % tolerance for fixed-point-residual
opts.verbose = 1; % display metrics
opts.L = 10; % number of Levels

%% calculation
tic;
[m,graphi,phi] = W1PDHG_ML(h, rho0, rho1, p, opts);
toc;

%% displaying
fprintf('energy:%f\n',PrimalFunL2(m, h));
%%
PlotFlow(x,y,m,rho0-rho1);
PlotPotential(x,y,phi);
%%
PlotFlow(orgx,orgy,m(1:120, 1:840,:),w1-w2);
PlotPotential(orgx,orgy,phi(1:120, 1:840));