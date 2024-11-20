function saveGridRocks(gridcases, names, folder, SPEcase)
    tagcase = 'allcells-bufferMult';
    for i = 1:numel(gridcases)
        simcase = Simcase('SPEcase', SPEcase, 'gridcase', gridcases{i}, 'tagcase', tagcase, 'deckcase', 'B_ISO_C', 'usedeck', true);
        simcase.saveGridRock(names{i}, 'folder', folder);
    end
end

