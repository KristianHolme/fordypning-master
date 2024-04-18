clear all;
close all;
%% Setup data
% getData = @(states,step, G) CellVelocity(states, step, G, 'g');cmap=''; dataname = 'CellVelocity';sumReduce = true; force = false;
% getData = @(states, step, G, simcase) states{step}.rs; cmap=''; dataname = 'rs'; sumReduce = false; force = false;
% getData = @(states, step, G, simcase) states{step}.s(:,2); cmap=''; dataname = 'CO2 saturation'; sumReduce = false;force = false;
% getData = @(states, step, G) G.cells.tag; cmap = '';dataname = 'facies index';sumReduce = false; force = false;
% getData = @(states, step, G, simcase) simcase.computeStaticIndicator; dataname ='ortherr'; cmap=''; sumReduce = true; force = true;
% getData = @(states, step, G, simcase) getFwerr(simcase);dataname ='fwerr'; cmap=''; sumReduce = true; force = true;
getData = @(states, step, G, simcase) getTotMass(states, step, simcase);cmap='';dataname='totMass'; sumReduce = true; force = false;
%% SPEcase, steps
SPEcase = 'B';
if strcmp(SPEcase, 'A') 
    scaling = hour; unit = 'h';
    steps = [30, 144, 720];
else 
    scaling = SPEyear;unit='y';
    % steps = [40, 150, 360];
    steps = [301];
end
%% Setup grid v disc

%A
% gridcases = {'5tetRef2', 'semi203x72_0.3', 'struct193x83'}; filename = 'MgridtypeComp';
% gridcases = {'5tetRef1', 'semi263x154_0.3', 'struct340x150'}; filename = 'FgridtypeComp';
% gridcases = { '5tetRef3', '5tetRef2','5tetRef1'}; filename = 'UU_refine_disc';
% gridcases = {'6tetRef2', '5tetRef2'}; filename = 'meshAlgComparisonRef2';
% gridcases = {'6tetRef1', '5tetRef1'}; filename = 'meshAlgComparisonRef1';
% gridcases = {'5tetRef2', '5tetRef2-2D'}; filename = 'UUgriddimComp';
% gridcases = {'semi203x72_0.3'}; filename = 'SS_M';
% gridcases = {'5tetRef10'};filename = 'coarse_nocap';
% pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-mpfa', 'hybrid-ntpfa'};
% pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-ntpfa'};



%B
% gridcases = {'5tetRef0.4', 'semi263x154_0.3', 'struct420x141'}; filename = 'FgridtypeComp';
% gridcases = {'5tetRef0.4', '5tetRef0.8', '5tetRef2'}; filename = 'UU_refine_disc';
% gridcases = {'6tetRef0.8', '5tetRef0.8'}; filename = 'meshAlgComparisonRef0.8';
% gridcases = {'6tetRef0.4', '5tetRef0.4'}; filename = 'meshAlgComparisonRef0.4';
% gridcases = {'5tetRef2', '5tetRef2-2D'}; filename = 'UUgriddimComp';
% gridcases = {'semi263x154_0.3','semi203x72_0.3',  'semi188x38_0.3'};filename = 'SS_refine_alldiscs';
% gridcases = {'5tetRef0.8', '5tetRef2-stretch'};filename = 'UU_M_stretch_comp';
% gridcases = {'6tetRef0.4', '5tetRef0.4', '5tetRef1-stretch'};filename = 'FmeshalgStretch';
% gridcases = {'5tetRef10', '5tetRef10'};filename = 'IMMISCIBLE_NTPFA';
% gridcases = {'struct420x141'};
% gridcases = {'', 'horz_pre_cut_PG_130x62', 'struct130x62', 'cart_pre_cut_PG_130x62'};filename = 'horz-cut-cart-cut';
% gridcases = {'horz_ndg_cut_PG_220x110', 'cart_ndg_cut_PG_220x110', 'cPEBI_220x110'};filename = 'cut-vs-pebi-M';
% gridcases = {'struct819x117', 'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117', '5tetRef0.31'};filename = 'C-Cut-P-T_F';
% gridcases = {'struct819x117', 'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117', 'gq_pb0.19', '5tetRef0.31'};filename = 'C-Cut-P-Q-T_F';
% gridcases = { 'cPEBI_819x117', '5tetRef0.31'};filename = 'pebi-unstruct-F';
% gridcases = {'struct220x110', 'struct819x117', 'struct2640x380'};filename = 'struct-refine';
gridcases = {'', 'struct130x62'};

% pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-ntpfa'};
% pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
pdiscs = {''};
jutul = {false};

subname = ''; %'', 'uppermiddle', 'middle'
[p1, p2] = getBoxPoints(subname, SPEcase, 3);


deckcase = 'B_ISO_C';
tagcases = {''};

plotgrid = false;
saveplot = true;
saveToReport = true;

filename = [SPEcase, '_', dataname, '_', filename];
savefolder=fullfile('./../plotsMaster/multiplot', subname);


numGrids = numel(gridcases);
numDiscs = numel(pdiscs);
%% Loading data grid vs pdisc
if numel(tagcases) ~= numGrids
    tagcases = repmat(tagcases, 1, numGrids);
end
if numel(jutul) ~= numGrids
    jutul = repmat(jutul, 1, numGrids);
end
data = cell(numDiscs, numGrids, numel(steps));
for istep = 1:numel(steps)
    step = steps(istep);
    for i = 1:numDiscs
        pdisc = pdiscs{i};
        for j = 1:numGrids
            gridcase = gridcases{j};
            simcase = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                                'tagcase', tagcases{j}, ...
                                'pdisc', pdisc, ...
                                'jutul', jutul{j});
            [states, ~, ~] = simcase.getSimData;
            G = simcase.G;
            if numelData(states) >= step || force
                statedata = getData(states, step, G, simcase);
                [inj1, inj2] = simcase.getinjcells;
                data{i, j, istep}.statedata = statedata;
                data{i, j, istep}.injcells = [inj1, inj2];
                data{i, j, istep}.G = G;
                data{i, j, istep}.cells = getSubCellsInBox(G, p1, p2);
                if i == 1
                    data{i, j, istep}.title = displayNameGrid(gridcase, simcase.SPEcase);
                end
                if j == 1
                    data{i, j, istep}.ylabel = shortDiscName(pdisc);
                end
            end
        end
    end
end
if force
    data = reshape(data, 3,2)';
    data{1,1}.ylabel = '';
end
%% Plotting grid vs disc
times = cumsum(simcase.schedule.step.val);
for istep = 1:numel(steps)
    step = steps(istep);
    plottitle = [dataname, ' at t=', num2str(round(times(step)/scaling)), unit];
    % multiplot(data(:, :, istep), 'title', plottitle, 'savefolder', savefolder, ...
    %     'savename', [filename, '_step', num2str(step)], ...
    %     'saveplot', saveplot, 'cmap', cmap, 'equal', false, 'plotgrid', plotgrid);   
    multiplot(data(:, :, istep), 'savefolder', savefolder, ...
        'savename', [filename, '_step', num2str(step)], ...
        'saveplot', saveplot, 'cmap', cmap, 'equal', false, 'plotgrid', plotgrid, ...
        'saveToReport', saveToReport); 
end
%% Setup full error plot/diff
% gridcase = '5tetRef0.4';
% gridcase = '5tetRef1';
% gridcase = 'semi263x154_0.3';
% gridcase = '6tetRef0.4';
% gridcase = '5tetRef0.4';
% gridcase = '5tetRef1-stretch';
% gridcase = 'cart_pre_cut_PG_130x62';

% gridcase = 'horz_ndg_cut_PG_819x117';
% gridcase = 'cart_ndg_cut_PG_819x117';
% gridcase = 'struct819x117';
% gridcase = 'cPEBI_819x117';
% gridcase = '5tetRef0.31';
% gridcase = 'gq_pb0.19';
gridcase = '';
% steps = [360];


% pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
% pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa'};
% pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-mpfa', 'hybrid-ntpfa'};
% pdiscs = {'', 'hybrid-avgmpfa'};
% pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
pdiscs = {'', ''};
% uwdiscs = {'', 'WENO'};
uwdiscs = {''};
deckcases = {'B_ISO_C', 'B_ISO_C_54C'};
tagcases = {''};%one for each pdisc or one that applies to all pdiscs


saveplot = false;
saveToReport = false;
bigGrid = false;
filename =[SPEcase, '_', dataname, '_diff_', gridcase, strjoin(cellfun(@(s)shortDiscName(s), pdiscs, UniformOutput=false), '_')];
savefolder = ['./../plotsMaster/differenceplots/', SPEcase, '/', displayNameGrid(gridcase, SPEcase)];
numpdiscs = numel(pdiscs);
numuwdiscs = numel(uwdiscs);
numDiscs = numpdiscs*numuwdiscs;
%% Load data diff
if numel(tagcases) ~= numDiscs
    tagcases = repmat(tagcases, 1, numDiscs);
end
if numel(deckcases) ~= numDiscs
    deckcases = repmat(deckcases, 1, numDiscs);
end
data = cell(numDiscs, numDiscs, numel(steps));
for istep = 1:numel(steps)
    step = steps(istep);
    for i = 1:numDiscs
        for j = i:numDiscs
            pdisc = pdiscs{ceil(j/numuwdiscs)};
            uwdisc = uwdiscs{customMod(j, numuwdiscs)};
            simcase = Simcase('SPEcase', SPEcase, 'deckcase', deckcases{ceil(j/numuwdiscs)}, 'usedeck', true, 'gridcase', gridcase, ...
                                'tagcase', tagcases{j}, ...
                                'pdisc', pdisc, 'uwdisc', uwdisc);
            [states, ~, ~] = simcase.getSimData;
            G = simcase.G;
            if numelData(states) >= step
                statedata = getData(states,step, G, simcase);
                [inj1, inj2] = simcase.getinjcells;
                data{i, j, istep}.statedata = statedata;
                data{i, j, istep}.injcells = [inj1, inj2];
                data{i, j, istep}.G = G;
                discName = shortDiscName(pdisc);
                if ~isempty(uwdisc)
                    discName = [discName, ', ', uwdisc];
                end
                if i == 1

                    data{i, j, istep}.title = discName;
                end
                if j == i
                    data{i, j, istep}.ylabel = discName;
                end
                %make diff
                if j ~= i
                    data{i, j, istep}.statedata = data{i, i, istep}.statedata - data{i, j, istep}.statedata;
                end
            end
        end
    end
    %add grid for plot in corner
    plotsize = numDiscs;
    switch plotsize
        case 5
            gridplotheight = 2;
            gridplotwidth = 2;
        case 4
            gridplotheight = 2;
            gridplotwidth = 2;
        case 3
            gridplotheight = 1;
            gridplotwidth = 2;
        case 2
            gridplotheight = 1;
            gridplotwidth = 1;
    end
    gridplotsize = floor(plotsize/2);
    i = plotsize + 1 - gridplotheight;
    data{i, 1, istep}.G = G;
    data{i, 1, istep}.title = displayNameGrid(gridcase, SPEcase);
    data{i, 1, istep}.span = [gridplotheight, gridplotwidth];

end


%% Plotting diff
if bigGrid
    apx = '_BigGrid';
else
    apx = '';
end
times = cumsum(simcase.schedule.step.val);
for istep = 1:numel(steps)
    step = steps(istep);
    plottitle = ['difference in ', dataname, ' at t=', num2str(round(times(step)/scaling)), unit, ' for grid: ', displayNameGrid(gridcase, SPEcase)];
    multiplot(data(:, :, istep), 'title', plottitle, 'savefolder', savefolder, ...
        'savename', [filename, '_step', num2str(step), apx], ...
        'saveplot', saveplot, 'cmap', 'Seismic', 'equal', strcmp(SPEcase, 'A'), ...
        'diff', true, 'bigGrid', bigGrid, 'saveToReport', saveToReport);   
end
%% Setup Grid diff plot
gridcases = {'struct819x117', 'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117', '5tetRef0.31', 'gq_pb0.19'};
% gridcases = {'struct819x117', 'horz_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_819x117', 'cPEBI_819x117', 'gq_pb0.19'};
% gridcases = {'horz_ndg_cut_PG_130x62', 'horz_ndg_cut_PG_220x110', 'horz_ndg_cut_PG_819x117'};
% gridcases = {'cart_ndg_cut_PG_130x62', 'cart_ndg_cut_PG_220x110', 'cart_ndg_cut_PG_819x117'};
% gridcases = {'struct819x117', 'struct1638x234', 'struct2640x380'};
% gridcases = {'horz_ndg_cut_PG_819x117', 'horz_ndg_cut_PG_1638x234', 'horz_ndg_cut_PG_2640x380'};
% gridcases = {'cart_ndg_cut_PG_819x117', 'cart_ndg_cut_PG_1638x234', 'cart_ndg_cut_PG_2640x380'};
% gridcases = {'struct2640x380', 'horz_ndg_cut_PG_2640x380', 'cart_ndg_cut_PG_2640x380'};
% gridcases = {'struct1638x234', 'horz_ndg_cut_PG_1638x234', 'cart_ndg_cut_PG_1638x234'};
% gridcases = {'', 'struct130x62'};

jutul = {false};
% pdiscs = {''};
% pdiscs = {'hybrid-avgmpfa'};
pdiscs = {'', 'cc', 'hybrid-avgmpfa', 'hybrid-ntpfa', 'hybrid-mpfa'};
tagcases = {''}; %one for each pdisc or one for all
uwdiscs = {''};


deckcases = {'B_ISO_C'};%one for each grid or one for all
saveplot = false;
saveToReport = false;
makeCorrTable = false;
makeEMDTable = true;
filename =[SPEcase, '_', dataname, '_diff_', strjoin(cellfun(@(g)displayNameGrid(g, SPEcase) , gridcases, UniformOutput=false), '_'), strjoin(cellfun(@(s)shortDiscName(s), pdiscs, UniformOutput=false), '_')];
savefolder = ['./../plotsMaster/gridDiff/', SPEcase];
numpdiscs = numel(pdiscs);
numuwdiscs = numel(uwdiscs);
numDiscs = numpdiscs*numuwdiscs;
numGrids = numel(gridcases);
%% Load Grid diff
if numel(tagcases) ~= numDiscs
    tagcases = repmat(tagcases, 1, numDiscs);
end
if numel(jutul) ~= numGrids
    jutul = repmat(jutul, 1, numGrids);
end
if numel(deckcases) ~= numGrids
    deckcases = repmat(deckcases, 1, numGrids);
end
simcases = {};
for ig = 1:numGrids
    for ipd = 1:numpdiscs
        for iud = 1:numuwdiscs
            newcase = Simcase('gridcase', gridcases{ig}, 'pdisc', pdiscs{ipd}, 'uwdisc', uwdiscs{iud}, ...
                'tagcase', tagcases{ipd}, 'deckcase', deckcases{ig}, 'usedeck', true, 'SPEcase', SPEcase, 'jutul', jutul{ig});
            [states, ~, ~] = newcase.getSimData;
            if numelData(states) >= steps(end)
                simcases{end+1} = newcase;
            end
            clear states;
        end
    end
end
numcases = numel(simcases);
data = cell(numcases, numcases, numel(steps));
diffnorms = zeros(numcases, numcases, numel(steps));
diffCorr = zeros(numcases, numcases, numel(steps));
energy = zeros(numcases, numcases, numel(steps));
for istep = 1:numel(steps)
    step = steps(istep);
    puredata = NaN(840*120, numel(simcases));
    for i = 1:numcases
        for j = i:numcases
            simcase = simcases{j};
            [states, ~, ~] = simcase.getSimData;
            G = simcase.G;
            if numelData(states) >= step
                statedata = getData(states,step, G, simcase);
                [inj1, inj2] = simcase.getinjcells;
                M = G.reductionMatrix;
                Gr = G.reductionGrid;
                indexMap = G.cells.indexMap;

                fulldata = zeros(size(M, 2), 1);
                

                if sumReduce %sums up quantitites, e.g. for total mass
                    fulldata(indexMap) = statedata ./ G.cells.volumes;
                    reducedData = (M*fulldata) .* Gr.cells.volumes;
                else %weights data, for e.g. pressure
                     fulldata(indexMap) = statedata;
                     reducedData = (M*fulldata);
                end

                data{i, j, istep}.statedata = reducedData;
                data{i, j, istep}.injcells = [inj1, inj2];
                data{i, j, istep}.G = Gr;
                discName = shortDiscName(simcase.pdisc);
                if ~isempty(simcase.uwdisc)
                    discName = [discName, ', ', uwdisc];
                end
                if i == 1
                    ;
                end
                if j == i
                    data{i, j, istep}.title = displayNameGrid(simcase.gridcase, simcase.SPEcase);
                    data{i, j, istep}.ylabel = discName;
                    puredata(:,i) = reducedData;
                end
                % R = corrcoef(data{i,i, istep}.statedata, data{i,j, istep}.statedata);
                % diffCorr(i,j, istep) = R(1,2);
                if makeEMDTable && j ~= i && j>i
                    flowenergy = approxEMD(data{i, i, istep}.statedata, data{i, j, istep}.statedata, 'verbose', true);
                    energy(i,j, istep) = flowenergy;
                    data{i,j,istep}.title = flowenergy;
                end
                %make diff
                if j ~= i
                    data{i, j, istep}.statedata = data{i, i, istep}.statedata - data{i, j, istep}.statedata;
                end
               
                diffnorms(i, j, istep) = norm(data{i, j, istep}.statedata);

            else
                
            end
        end
    end
    diffCorr(:,:,istep) = corrcoef(puredata);
end
if makeCorrTable
    diffcorr = round(diffCorr, 3);
    triudiffcorr = triu(diffCorr);
    % triudiffcorr(triudiffcorr == 0) = NaN;
    cellDiffCorr = num2cell(diffcorr);
    for i = 1:(numel(simcases))
        cellDiffCorr{i,i} = [displayNameGrid(simcases{i}.gridcase, simcases{i}.SPEcase), ', ', shortDiscName(simcases{i}.pdisc)];
    end
    Tcorr = cell2table(cellDiffCorr);
    displaynames = cellfun(@(s)displayNameGrid(s.gridcase, s.SPEcase), simcases, 'UniformOutput',false);
    discnames = cellfun(@(s)shortDiscName(s.pdisc),simcases, UniformOutput=false);
    table2latex(Tcorr, fullfile('./../rapport/Tables/corr', [strjoin(unique(displaynames),'_'), '_', strjoin(unique(discnames), '_'), '.tex']), 'colheaders', false);
end
if makeEMDTable
    energy = energy + energy';
    cellEnergy = num2cell(energy);
    for i = 1:(numel(simcases))
        cellEnergy{i,i} = [displayNameGrid(simcases{i}.gridcase, simcases{i}.SPEcase), ', ', shortDiscName(simcases{i}.pdisc)];
    end
    Tenergy = cell2table(cellEnergy);
    displaynames = cellfun(@(s)displayNameGrid(s.gridcase, s.SPEcase), simcases, 'UniformOutput',false);
    discnames = cellfun(@(s)shortDiscName(s.pdisc),simcases, UniformOutput=false);
    table2latex(Tenergy, fullfile('./../rapport/Tables/EMD', [strjoin(unique(displaynames),'_'), '_', strjoin(unique(discnames), '_'), '.tex']), 'colheaders', false);
end
%% Plot grid diff
times = cumsum(simcase.schedule.step.val);
for istep = 1:numel(steps)
    step = steps(istep);
    plottitle = ['difference in ', dataname, ' at t=', num2str(round(times(step)/scaling)), unit];
    multiplot(data(:, :, istep), 'title', plottitle, 'savefolder', savefolder, ...
        'savename', [filename, '_step', num2str(step)], ...
        'saveplot', saveplot, 'cmap', 'Seismic', 'equal', strcmp(SPEcase, 'A'), ...
        'diff', true, 'saveToReport', saveToReport);   
end

%% Setup time evolution plot
% gridcases = {'5tetRef0.4', '5tetRef1-stretch'}; pdiscs = {'hybrid-mpfa', 'hybrid-mpfa'};%one for each grid
% gridcases = {'5tetRef10', '5tetRef10'}; pdiscs = {'', 'hybrid-ntpfa'};
% gridcases = {'5tetRef0.4', '6tetRef0.4'}; pdiscs = {'', ''};

% gridcases = { '5tetRef3', '5tetRef2','5tetRef1'}; pdiscs = {'','',''};
% gridcases = {'5tetRef2', '5tetRef0.8', '5tetRef0.4'}; pdiscs = {'hybrid-avgmpfa','hybrid-avgmpfa','hybrid-avgmpfa'};
gridcases = {'semi188x38_0.3','semi203x72_0.3','semi263x154_0.3'};pdiscs = {'','',''};
% gridcases = {'5tetRef10', '5tetRef10', '5tetRef10'}; pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-ntpfa'};
% % pdiscs = {'', 'hybrid-avgmpfa', 'hybrid-mpfa', 'hybrid-ntpfa'};

filename =[SPEcase, '_timeEvo_', dataname, '_', strjoin(cellfun(@(x, y) [x '-' shortDiscName(y)], gridcases, pdiscs, 'UniformOutput', false), '_')];
assert(numel(pdiscs)==numel(gridcases))
deckcase = 'RS';
tagcase = '';


saveplot = true;
savefolder = 'plots/timeEvolution';

numcases = numel(pdiscs);
%% Load timeEvo data
data = cell(numel(steps), numcases);
for i = 1:numcases
    gridcase = gridcases{i};
    pdisc = pdiscs{i};
    simcase = Simcase('SPEcase', SPEcase, 'deckcase', deckcase, 'usedeck', true, 'gridcase', gridcase, ...
                            'tagcase', tagcase, ...
                            'pdisc', pdisc);
    [states, ~, ~] = simcase.getSimData;
    G = simcase.G;
    if i == 1
        times = cumsum(simcase.schedule.step.val);
    end
    for istep = 1:numel(steps)
        step = steps(istep);
        if numelData(states) >= step
            statedata = getData(states, step, G);
            [inj1, inj2] = simcase.getinjcells;
            data{istep, i}.statedata = statedata;
            data{istep, i}.injcells = [inj1, inj2];
            data{istep, i}.G = G;
            if istep == 1
                data{istep, i}.title = [displayNameGrid(gridcase, SPEcase), ', ', shortDiscName(pdisc)];
            end
            if i == 1
                data{istep, i}.ylabel = [num2str(round(times(step)/scaling)), ' ', unit];
            end
        end
    end
end
%% Plotting timeEvo

plottitle = ['time evolution of ', dataname];
% multiplot(data, 'title', plottitle, 'savefolder', savefolder, ...
        % 'savename', filename, 'saveplot', saveplot, 'cmap', cmap, 'equal', strcmp(SPEcase, 'A'));
multiplot(data, 'savefolder', savefolder, 'savename', filename, 'saveplot', saveplot, 'cmap', cmap, 'equal', strcmp(SPEcase, 'A'));
%%
function fwerr = getFwerr(simcase)
[~, ~, fwerr] = simcase.computeStaticIndicator;
end