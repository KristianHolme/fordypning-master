function latexTable = triTab2Latex(T, simNames, gridname)
numSims = size(T, 1);
% Generate LaTeX code for the table
latexTable = '\\begin{table}[h]\n\\centering\n\\begin{tabular}{l';
for i = 1:numSims
    latexTable = strcat(latexTable, 'l');
end
% latexTable = strcat(latexTable, '}\n\\hline\n & ', strjoin(simNames, ' & '), ' \\\\\n\\hline\n');
latexTable = strcat(latexTable, '}\n');
for i = 1:numSims
    % latexTable = strcat(latexTable, simNames{i}, ' & ');
    for j = 1:i-1
        latexTable = [latexTable, sprintf('%.2f', T{i, j}), ' & '];
    end
    latexTable = [latexTable, simNames{i}, '\\\\\n'];
end

latexTable = strcat(latexTable, ['\\end{tabular}\n\\caption{L1 differences [$10^6$ kg] between ',...
    '\\coo mass from simulations on the ', gridname, ' grid}\n\\label{tab:L1diff_', gridname,'}\n\\end{table}']);

% Display the LaTeX code
% disp(latexTable);
end