f = gcf;
f.Color = [1 1 1];
for i=1:numel(f.Children.Children)
    if strcmp(get(f.Children.Children(i), 'type'), 'axes')
        set(f.Children.Children(i),'XTick',[],'Ytick',[],'ZTick',[],...
            'Color', [167,166,163]/255,'FontSize',14);
    end
end
% C = parula.^2;
C = load('seaborn_icefire_gradient.mat'); C=C.colormap;
C(1,:) = .97;
colormap(C);