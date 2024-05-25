function f = plotbar3(data, gridnames, discnames, gridcolors, title, valuelabel)
data = data(end,:); %extract last row
data = reshape(data, numel(discnames), numel(gridnames));
f = figure;
set(f, 'Name', title);
h = bar3(data);
set(gca, 'XTickLabel', gridnames);
set(gca, 'YTickLabel', discnames);
zlabel(valuelabel);
for k = 1:length(h)
    set(h(k), 'FaceColor', gridcolors{k});
    zdata = get(h(k), 'ZData');
    % Set NaN bars visibility off
    for j = 1:size(data, 1)
        if isnan(data(j, k))
            h(k).ZData(j*6-5:j*6, :) = NaN; % Hide the corresponding bars
        end
    end
end
view(36,25)