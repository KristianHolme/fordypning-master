function faceBlocks = getFaceBlocks(G, cellblocks)
    tpfaCells = cellblocks{1};
    tpfaFaces = G.cells.faces(mcolon(G.cells.facePos(tpfaCells), G.cells.facePos(tpfaCells+1)-1));
    faceBlocks{1} = tpfaFaces;
    otherFaces = setdiff(1:G.cells.num, tpfaFaces);
    faceBlocks{2} = otherFaces;
end