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
n1 = 1000;
n2 = 520;
w1 = rand(n1, 1);
w2 = rand(n2,1);
f1 = rand(n1, 3);
f2 = rand(n2, 3);
dist = f1*f2';

opts = optimoptions('linprog', 'UseParallel',true);
opts.MaxTime = 100;

tic();
[x, fval] = emd(f1, f2, w1, w2, dist, opts);fval
toc()