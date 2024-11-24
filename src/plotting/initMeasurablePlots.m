function [getData, plotTitle, ytxt, folder, filetag] = initMeasurablePlots(plotType, resetData)
    % Initialize plotting parameters for different measurable plots
    %
    % Parameters:
    %   plotType (string): Type of plot to initialize ('sealing', 'faultflux', 
    %                      'buffer', 'pop1', 'pop2', 'p21', 'p22', etc.)
    %   resetData (logical): Whether to reset cached data
    %
    % Returns:
    %   getData (function): Function handle to get plot data
    %   plotTitle (string): Title for the plot
    %   ytxt (string): Y-axis label
    %   folder (string): Output folder path
    %   filetag (string): Tag for filename

    switch lower(plotType)
        case 'sealing'
            [getData, plotTitle, ytxt, folder, filetag] = initSealingPlot(resetData);
        case 'faultflux'
            [getData, plotTitle, ytxt, folder, filetag] = initFaultFluxPlot(resetData);
        case 'buffer'
            [getData, plotTitle, ytxt, folder, filetag] = initBufferPlot(resetData);
        case {'pop1', 'pop2'}
            popcell = str2double(plotType(end));
            [getData, plotTitle, ytxt, folder, filetag] = initPoPPlot(popcell, resetData);
        case {'p21', 'p22', 'p23', 'p24'}
            submeasure = str2double(plotType(end));
            [getData, plotTitle, ytxt, folder, filetag] = initBoxAPlot(submeasure, resetData);
        case {'p31', 'p32', 'p33', 'p34'}
            submeasure = str2double(plotType(end));
            [getData, plotTitle, ytxt, folder, filetag] = initBoxBPlot(submeasure, resetData);
        otherwise
            error('Unknown plot type: %s', plotType);
    end
end

function [getData, plotTitle, ytxt, folder, filetag] = initSealingPlot(resetData)
    getData = @(simcase, steps)getSealingCO2(simcase, steps, 'resetData', resetData);
    plotTitle = 'CO2 in sealing units';
    ytxt = 'CO2 [kg]';
    folder = './plots/sealingCO2';
    filetag = 'sealingCO2';
end

function [getData, plotTitle, ytxt, folder, filetag] = initFaultFluxPlot(resetData)
    getData = @(simcase, steps)getFaultFluxes(simcase, steps, 'resetData', resetData);
    plotTitle = 'CO2 fluxes over region boundaries (sum(abs(flux)))';
    ytxt = 'sum(abs(Fluxes))';
    folder = './plots/faultfluxes';
    filetag = 'faultflux';
end

function [getData, plotTitle, ytxt, folder, filetag] = initBufferPlot(resetData)
    getData = @(simcase, steps)getBufferCO2(simcase, steps, 'resetData', resetData);
    plotTitle = 'CO2 in buffer volumes';
    ytxt = 'CO2 [kg]';
    folder = './plots/bufferCO2';
    filetag = 'bufferCO2';
end

function [getData, plotTitle, ytxt, folder, filetag] = initPoPPlot(popcell, resetData)
    getData = @(simcase, steps)getPoP(simcase, steps, popcell, 'resetData', resetData) ./barsa;
    plotTitle = sprintf('Pressure at PoP %d', popcell);
    ytxt = 'Pressure [bar]';
    folder = './plots/PoP';
    filetag = sprintf('pop%d', popcell);
end

function [getData, plotTitle, ytxt, folder, filetag] = initBoxAPlot(submeasure, resetData)
    box = 'A';
    ytxt = 'CO2 [kg]';
    titles = {'Mobile CO2', 'Immobile CO2', 'Dissolved CO2', 'Seal CO2'};
    plotTitle = sprintf('P2.%d %s', submeasure, titles{submeasure});
    folder = './plots/composition/P2boxA';
    filetag = ['box', box, getMeasureTag(submeasure)];
    getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
end

function [getData, plotTitle, ytxt, folder, filetag] = initBoxBPlot(submeasure, resetData)
    box = 'B';
    ytxt = 'CO2 [kg]';
    titles = {'Mobile CO2', 'Immobile CO2', 'Dissolved CO2', 'Seal CO2'};
    plotTitle = sprintf('P3.%d %s', submeasure, titles{submeasure});
    folder = './plots/composition/P3boxB';
    filetag = ['box', box, getMeasureTag(submeasure)];
    getData = @(simcase, steps)getComp(simcase, steps, submeasure, box, 'resetData', resetData);
end

function tag = getMeasureTag(submeasure)
    tags = {'mob', 'immob', 'diss', 'seal'};
    tag = tags{submeasure};
end