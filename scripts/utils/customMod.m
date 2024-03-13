function m = customMod(a, b)
m = mod(a,b);
if m == 0 && a~=0
        m = b;
end
end