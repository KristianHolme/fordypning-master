function neighbors = getnbsByConn(Conn)
    [I, J] = find(Conn);
    sz = J(end);
    [~, nbs] = rlencode(J);
    pos = cumsum([1;nbs]);
    neighbors = cell(sz,1);
    for i = 1:sz
        nbs = I(pos(i):pos(i+1)-1);
        neighbors{i} = nbs;
    end
end