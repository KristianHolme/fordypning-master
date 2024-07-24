function maxval = cellmax(x)
maxval = -Inf;
for i = 1:numel(x)
    maxval = max(maxval, max(x{i}));
end
end