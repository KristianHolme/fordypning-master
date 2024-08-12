function activeWeights = getCSPBoxWeights(G, box, SPEcase)
    if ~isfield(G.cells, ['fractionIn', box])
        G = addBoxWeights(G, 'SPEcase', SPEcase);
    end
    allweights = G.cells.(['fractionIn', box]);
    activeWeights = allweights(G.cells.indexMap);
end
