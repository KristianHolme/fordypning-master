function VizCoarse(CG)
    %Viz CoarseGrid
    cla
    plotCellData(CG, CG.cells.tag, 'EdgeColor','w','EdgeAlpha',.5);
    plotFaces(CG, (1:CG.faces.num)', 'FaceColor','none','LineWidth', 2);
end