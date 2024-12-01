clear all
close all
%%
SPEcase = 'B';
[gridcases, gridnames] = getRSCGridcases({'C', 'HC', 'CC', 'PEBI','QT', 'T'}, [100]);
% [gridcases, gridnames] = getRSCGridcases({'C', 'HC', 'CC','QT', 'T'}, [10]);
pdiscs = {'', 'avgmpfa', 'ntpfa', 'mpfa'};
%%
simcases = loadSimcases(gridcases, pdiscs);
%%
name = 'mrst100k';
%%
energy = calcEMD(simcases, name);
%%
plotEMD(energy, simcases, name);

%%
function simcases = loadSimcases(gridcases, pdiscs, varargin)
    opt = struct('SPEcase', 'B',...
                 'jutulComp', '');
    opt = merge_options(opt, varargin{:});
    simcases = {};

    for igrid = 1:numel(gridcases)
        gridcase = gridcases{igrid};
        for idisc = 1:numel(pdiscs)
            pdisc = pdiscs{idisc};
            if isempty(opt.jutulComp) && ~strcmp(pdisc, '')
                simcasepdisc = ['hybrid-', pdisc];
            else
                simcasepdisc = pdisc;
            end
            if ~isempty(opt.jutulComp)
                tagcase = 'allcells';
            else
                tagcase = '';
            end
            newsimcase = Simcase('SPEcase', opt.SPEcase, ...
                                      'deckcase', 'B_ISO_C', ...
                                      'usedeck', true, ...
                                      'gridcase', gridcase, ...
                                      'pdisc', simcasepdisc,...
                                      'jutulComp', opt.jutulComp,...
                                      'tagcase', tagcase);
            states = newsimcase.getSimData;
            if numelData(states) > 1
                simcases{end+1} = newsimcase;
            end
        end
    end
end

function EMD_energy = calcEMD(simcases, name, varargin)
    opt = struct('dir', './data/RSC/EMD',...
                 'save', true);
    opt = merge_options(opt, varargin{:});
    n = numel(simcases);
    EMD_energy = nan(n);

    tot_entries = n*(n-1)/2;

    indicesarray=zeros(round(tot_entries), 2);
    k = 0;
    for i = 1:n
        EMD_energy(i,i) = 0.0;
        for j = i+1:n
            k = k + 1;
            indicesarray(k,1) = i;
            indicesarray(k,2) = j;
        end
    end

    
    % Convert nested loops to single loop with linear indexing
    EMD_tmp = zeros(tot_entries, 1);  % Store results in a temporary vector
    
    for k = 1:tot_entries % can be made parallel, not recommended
        i = indicesarray(k,1);
        j = indicesarray(k,2);
        statesj = simcases{j}.getSimData;
        statesi = simcases{i}.getSimData;
        statej = statesj{numelData(statesj)}.FlowProps.ComponentTotalMass{2};
        statei = statesi{numelData(statesi)}.FlowProps.ComponentTotalMass{2};
        Gj = simcases{j}.G; 
        Gi = simcases{i}.G;
        Mj = simcases{j}.G.reductionMatrix;
        Mi = simcases{i}.G.reductionMatrix;
        Grj = simcases{j}.G.reductionGrid;
        Gri = simcases{i}.G.reductionGrid;
        EMD_tmp(k) = approxEMD(reduce(statei, Gi, Mi, Gri), reduce(statej, Gj, Mj, Grj), 'verbose', true);
    end
    
    % Convert back to matrix form after parallel loop
    for k = 1:tot_entries
        i = indicesarray(k,1);
        j = indicesarray(k,2);
        EMD_energy(i,j) = EMD_tmp(k);
    end
    
    if opt.save
        pth = fullfile(opt.dir, sprintf('%s.mat', name));
        save(pth, 'EMD_energy');
    end
end


function plotEMD(EMD_energy, simcases, name, varargin)
    % Parse options
    opt = struct('dir', 'plots/RSC/EMD', ...
                'save', true);
    opt = merge_options(opt, varargin{:});
    
    % Normalize the EMD energy matrix
    EMD_energy = EMD_energy';
    % EMD_energy = EMD_energy / max(EMD_energy(:));
    
    % Create labels combining grid and discretization info
    labels = cell(numel(simcases), 1);
    for i = 1:numel(simcases)
        gridname = gridcase_to_RSCname(simcases{i}.gridcase);
        discname = shortDiscName(simcases{i}.pdisc);
        labels{i} = sprintf('%s\n%s', gridname, discname);
    end
    
    % Create plot
    figure('Position', [100 100 1000 800], 'Name', sprintf('EMD, %s', name));
    h = imagesc(EMD_energy);
    
    % Set missing data to white
    cdata = get(gca, 'Children');
    set(cdata, 'AlphaData', ~isnan(EMD_energy));
    % clim([0 1]);
    
    % Add labels
    set(gca, 'XTick', 1:length(labels), 'YTick', 1:length(labels));
    set(gca, 'XTickLabel', labels, 'YTickLabel', labels);
    xtickangle(45);
    
    % Customize appearance
    colorbar();
    colormap(hot);
    axis square;
    set(gca, 'FontSize', 10);
    
    % Save plots if requested
    if opt.save
        if ~exist(opt.dir, 'dir')
            mkdir(opt.dir);
        end
        saveas(gcf, fullfile(opt.dir, [name, '_EMD.png']));
        saveas(gcf, fullfile(opt.dir, [name, '_EMD.fig']));
    end
end

function reducedData = reduce(statedata, G, M, Gr)
    fulldata = zeros(size(M, 2), 1);
    fulldata(G.cells.indexMap) = statedata ./ G.cells.volumes;
    reducedData = (M*fulldata) .* Gr.cells.volumes;
end

