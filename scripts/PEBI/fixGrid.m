function G = fixGrid(G)
% fix duplicate nodes and faces, on 2D grid after PEBI-gen

nodecoords = round(G.nodes.coords, 5 );
[uqcoords, uqIxs] = uniqueNodes(nodecoords);
repeatedNodes = find(accumarray(uqIxs,1) ==2);
for irn = 1:numel(repeatedNodes)
    rn = repeatedNodes(irn);
    mergingNodes = uqIxs == rn;
    uqcoords(rn,:) = sum(G.nodes.coords(mergingNodes, :), 1) /2;
end
G.nodes.coords = uqcoords;
G.nodes.num = size(uqcoords, 1);

G.faces.nodes = uqIxs(G.faces.nodes);
assert(all(diff(G.faces.nodePos)==2));
facenodes = [G.faces.nodes(1:2:end),G.faces.nodes(2:2:end)];
facenodes = sort(facenodes, 2);


%remove degenerate faces
degFaces = facenodes(:,1) == facenodes(:,2);
G = removeFaces(G, find(degFaces));
facenodes = facenodes(~degFaces,:);
[fn, fnixA, fnixC] = unique(facenodes, "rows", 'stable');
counts = accumarray(fnixC, 1);
repeated = find(counts > 1);
facesToRemove = false(G.faces.num,1);
for irf = 1:numel(repeated)
    rf = repeated(irf);
    merging = find(fnixC == rf);
    assert(numel(merging)==2);
    assert(all(any(G.faces.neighbors(merging,:) == 0,2)), 'both doesnt have a zero neighbor');
    cells = sum(G.faces.neighbors(merging,:), 2);

    zeronb = find(G.faces.neighbors(merging(1),:) == 0);
    G.faces.neighbors(merging(1), zeronb) = cells(2);
    
    facesToRemove(merging(2)) = true;
    G.cells.faces(G.cells.faces == merging(2)) = merging(1);
end
[G.cells.faces, G.cells.facePos] = removeFromPackedData(G.cells.facePos, G.cells.faces, find(facesToRemove));
[G, facemap] = removeFaces(G, find(facesToRemove));
G = computeGeometry(G); 

end

