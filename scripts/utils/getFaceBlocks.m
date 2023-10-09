function faceBlocks = getFaceBlocks(G, cellblocks)
    tpfaCells = cellblocks{1};
    tpfaFaces = unique(G.cells.faces(mcolon(G.cells.facePos(tpfaCells), G.cells.facePos(tpfaCells+1)-1)));
    faceBlocks{1} = tpfaFaces;
    otherFaces = setdiff(1:G.faces.num, tpfaFaces);
    faceBlocks{2} = otherFaces;
    assert(numel(faceBlocks{1}) + numel(faceBlocks{2}) == G.faces.num)
end