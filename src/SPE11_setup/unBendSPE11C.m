function c = unBendSPE11C(c)
v = c(:,2);
w = c(:,3);

z = w + 150*(1-(v/2500 - 1).^2) + v/500;
c(:,3) = z;
end