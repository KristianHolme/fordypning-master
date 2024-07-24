spy(A)
%%
name = [gridcases{1}, ', SPE11C'];
title(name, 'Interpreter','none');
exportgraphics(gcf, ['./../plots/sparsity/', name, '.png']);