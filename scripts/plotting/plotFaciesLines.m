% Load SPE11 case and grid
SPEcase = 'B';
deckcase = 'B_ISO_C';
simcase = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true);

% Get the grid and facies data
G = simcase.G;
facies = G.cells.tag;

geoH = readHorizons();
figure;
for i=1:8
    axis([0,2.8, 0, 1.2]);
    pts = geoH.horz{i, 3};
    plot(pts(:,1), pts(:,2))
    hold on;
end