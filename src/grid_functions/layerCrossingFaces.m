function layerCrossingFaces = layerCrossingFaces(G)
neighbors = G.faces.neighbors;
neighborTags = neighbors;
for i=1:2
    nonzeros = neighbors(:,i) ~= 0;
    neighborTags(nonzeros,i) = G.cells.tag(neighbors(nonzeros, i));
end
internal = (neighborTags(:,1) ~= 0) & (neighborTags(:,2) ~= 0);
% internal = simcase.model.operators.internalConn;
layerCrossingFaces = (neighborTags(:,1) ~= neighborTags(:,2)) & internal;
end