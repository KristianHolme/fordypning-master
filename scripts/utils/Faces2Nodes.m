function n = Faces2Nodes(f, G)
    n = vertcat(G.faces.nodesByFace{f});
end

function n = Faces2Nodes2(f, G)
    ni = mcolon(G.faces.nodePos(f), ...
                G.faces.nodePos(f+1)-1)';

    % pos = cumsum([1; double(nnode(f))]);
    n = G.faces.nodes(ni);
end
