function weights = getCSPBoxWeights(G, box, SPEcase)
    if ~isfield(G.cells, ['fractionIn', box])
        G = addBoxWeights(G, 'SPEcase', SPEcase);
    end
    weights = G.cells.(['fractionIn', box]);
end
