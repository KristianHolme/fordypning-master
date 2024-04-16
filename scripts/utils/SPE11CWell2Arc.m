function z = SPE11CWell2Arc(y)
z = sqrt(1 + (-0.12 * (y*4e-4 - 1) + 2e-3).^2);
end