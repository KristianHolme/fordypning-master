function z = well2ArcSPE11C(y)
z = sqrt(1 + (-0.12 * (y*4e-4 - 1) + 2e-3).^2);
end