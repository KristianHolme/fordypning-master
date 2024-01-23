clear all
close all

%%
geoH = readHorizons();
geodata = readGeo('');
%%
Lx = 2.8;
Ly = 1.2;
nx = 4;
ny = 4;
G = cartGrid([nx ny 1], [Lx Ly 0.01]);
G =computeGeometry(G);
%% Add Top as first horizon
horzInters = geoH.horz(:,4);
horzInters = [{@(newxs)interp1([0.0, 2.8], [1.2, 1.2], newxs, 'linear')}; horzInters];
%% Make subgrids
top = horzInters{1};
bottom = horzInters{2};
nxs = [20, 20, 20, 20, 20, 20, 20, 20, 20];
nys = [4, 5, 6, 7, 8, 9, 10, 11, 10];
cartGrids = {};
for ihorz = 1:numel(horzInters)-1
    top = horzInters{ihorz};
    bottom = horzInters{ihorz+1};

    nx = nxs(ihorz);
    ny = nys(ihorz);
    Gcart = cartGrid([nx, ny], [Lx, Ly]);
    for j = 1:ny+1
        jpos = (j-1)*(nx+1) + 1;
        xs = Gcart.nodes.coords(jpos:jpos+nx, 1);
        topys = top(xs);
        botys = bottom(xs);
        lambda = (j-1)/(ny);
        ys = botys*(1-lambda) + lambda*topys;
        Gcart.nodes.coords(jpos:jpos+nx, 2) = ys;
    end
    Gcart = computeGeometry(Gcart);
    cartGrids{ihorz} = Gcart;
end
%% Plot subgrids
clf
for i=1:9
    % clf
    axis([0,2.8, 0, 1.2]);
    plotGrid(cartGrids{i});
    ;
end
%% Volume fractions
gridvolumes = cellfun(@(G)sum(G.cells.volumes), cartGrids);
gridfractions = gridvolumes/sum(gridvolumes);
%% Glue grids together
G = cartGrids{1};
for i=2:numel(cartGrids)
    G = glue2DGrid(G, cartGrids{i});
end
G = computeGeometry(G);
%% plot horizonlines
figure;
for i=1:8
    axis([0,2.8, 0, 1.2]);
    pts = geoH.horz{i, 3};
    plot(pts(:,1), pts(:,2))
    hold on;
end

%% Not sure
horzLines = horzcat(geoH.horz{:,2});
geoH.boundaryLines = setdiff(1:numel(geoH.Line), horzLines);
horzPoints = geoH.Line(horzLines);
horzPoints = unique([horzPoints{:}]);
%% Functions

