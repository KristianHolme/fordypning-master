function bc = setupBC11A(G)
    topBCfaces = find(G.faces.centroids(:,3) == 0.0);
    bc = addBC([], topBCfaces, 'pressure', 1.1e5*Pascal, ...
        'sat', [1,0]);
end