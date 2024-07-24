function plotHybridCellblocks(G, cellblocks)
plotGrid(G, 'facealpha', 0);view(0,0);
plotGrid(G, cellblocks{2});
axis tight;
end