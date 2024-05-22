function VizCoarse(CG)
    %Viz CoarseGrid
    cla
    plotCellData(CG, CG.cells.tag, 'EdgeColor','w','EdgeAlpha',.5, 'LineWidth', 2);view(0,0);
    hold on;
    plotFaces(CG, (1:CG.faces.num)', 'FaceColor','none','LineWidth', 4, 'EdgeColor', 'k');
end