classdef Simcase < handle
    properties
        casename 
        

        propnames
        SPEcase
        gridcase
        fluidcase
        tagcase
        schedulecase
        rockcase
        deckcase
        usedeck
        pdisc %eks. pressure discretization'hybrid-avgmpfa'
        uwdisc
        jutul

        G
        rock
        fluid
        schedule
        model
        deck
        user
        dataOutputDir
        spe11utilsDir
        spe11decksDir
        decksaveDir
        repoDir
        griddim
        
        
        gravity

    end
    properties (Access = private)
        resetprop  % trigger reset of properties in getters and setters (default = 1)
        updateprop % trigger update of properties in getters and setters (default = 1)
    end
    methods

        function simcase = Simcase(varargin)
            opt = struct('casename'     , [], ...
                         'SPEcase'      , 'A', ...
                         'gridcase'     , '', ...
                         'fluidcase'    , [], ...
                         'tagcase'      , '', ...
                         'deckcase'     , [], ...
                         'usedeck'      , false, ...
                         'schedulecase' , [], ...
                         'deck'         , [], ...
                         'rockcase'     , [], ...
                         'pdisc'   , '', ...
                         'griddim'      , 3, ...
                         'uwdisc'      , [], ...
                         'jutul'       , false);
            opt = merge_options(opt, varargin{:});

            propnames = {'SPEcase', 'deckcase', 'gridcase', 'pdisc', 'uwdisc', 'fluidcase', 'tagcase',...
                'schedulecase'};
            
            simcase.updateprop = false;
            simcase.resetprop = false;

            simcase.casename = opt.casename;
            for i = 1:numel(propnames)
                pn = propnames{i};
                simcase.(pn) = opt.(pn);
            end
           

            simcase.propnames = propnames;
            simcase.usedeck = opt.usedeck;
            simcase.jutul = opt.jutul;
            
            %configure folder structure
            configFile = fileread('config.JSON');
            config = jsondecode(configFile);
            simcase.dataOutputDir = config.output_folder;
            simcase.spe11utilsDir = config.spe11utils_folder;
            simcase.decksaveDir = config.decksave_folder;
            simcase.repoDir = config.repo_folder;
            simcase.spe11decksDir = config.spe11decks_folder;

            simcase.updateprop = true;
            simcase.resetprop  = true;

             if contains(simcase.gridcase, '-2D')
                opt.griddim = 2;
            end
            simcase.griddim = opt.griddim;
        end

        function casename = get.casename(simcase)
            casename = simcase.casename;
            if isempty(casename) && simcase.updateprop
                casename = ConstructCasename(simcase);
                simcase.casename = casename;
            end
        end

        function casename = ConstructCasename(simcase)
            casename = [];
            for i = 1:numel(simcase.propnames)
                pn = simcase.propnames{i}; 
                if ~isempty(simcase.(pn))
                    casename = [casename,strrep(pn, 'case', ''), '=', simcase.(pn), '_'];
                end
            end
            casename = replace(casename, 'SPE=', '');
            casename = casename(1:end-1);
        end
        function resetProps(simcase)
            simcase.G = []; %reset grid
            simcase.fluid = [];
            simcase.schedule = [];
            simcase.rock = [];
            simcase.model = [];
            simcase.deck = [];

        end

        function simcase = set.SPEcase(simcase, SPEcase)
            simcase.SPEcase = SPEcase;
            if simcase.updateprop
                simcase.casename = simcase.ConstructCasename();
            end
        end

        function simcase = set.gridcase(simcase, gridcase)
            simcase.gridcase = gridcase;
            if simcase.updateprop
                simcase.casename = simcase.ConstructCasename();
                simcase.resetProps;
            end
        end

        function simcase = set.fluidcase(simcase, fluidcase)
            simcase.fluidcase = fluidcase;
            if simcase.updateprop
                simcase.casename = simcase.ConstructCasename();
                simcase.resetProps;
                
            end
        end
        function simcase = set.schedulecase(simcase, schedulecase)
            simcase.schedulecase = schedulecase;
            if simcase.updateprop
                simcase.casename = simcase.ConstructCasename();
                simcase.resetProps;                
            end
        end

        function simcase = set.tagcase(simcase, tagcase)
            simcase.tagcase = tagcase;
            if simcase.updateprop
                simcase.casename = simcase.ConstructCasename();
            end
        end

        function simcase = set.rockcase(simcase, rockcase)
            simcase.rockcase = rockcase;
            if simcase.updateprop
                simcase.casename = simcase.ConstructCasename();
                simcase.resetProps;
            end
        end
        function simcase = set.deckcase(simcase, deckcase)
            simcase.deckcase = deckcase;
            if simcase.updateprop
                simcase.casename = simcase.ConstructCasename();
                simcase.resetProps;
            end
        end

        function simcase = set.pdisc(simcase, pdisc)
            simcase.pdisc = pdisc;
            if simcase.updateprop
                simcase.casename = simcase.ConstructCasename();
                simcase.resetProps;
            end
        end
        function simcase = set.uwdisc(simcase, uwdisc)
            simcase.uwdisc = uwdisc;
            if simcase.updateprop
                simcase.casename = simcase.ConstructCasename();
                simcase.resetProps;
            end
        end

        function griddim = get.griddim(simcase)
            %if gridcase exists then default to griddim 3 if
            %not gridcase contains "-2D"
            griddim = simcase.griddim;
            if isempty(griddim)
                gridcase = simcase.gridcase;
                if ~isempty(gridcase)
                    if contains(gridcase, '-2D')
                        griddim = 2;
                    else
                        griddim = 3;
                    end
                end
            end
        end


        function schedule = get.schedule(simcase)
            schedule = simcase.schedule;
            if isempty(schedule)
                schedule = setupSchedule(simcase);
                simcase.schedule = schedule;
            end
        end

        function deck = get.deck(simcase)
            deck = simcase.deck;
            if isempty(deck)
                deckname = simcase.deckcase;
                if contains(deckname, 'B_ISO_C')
                    deckname = 'CSP11B_DISGAS.DATA';
                    deckFolder = fullfile(simcase.spe11decksDir, 'csp11b', 'isothermal', '130_62');
                elseif contains(deckname, 'B_ISO_F')
                    deckname = 'CSP11B_DISGAS.DATA';
                    deckFolder = fullfile(simcase.spe11decksDir, 'csp11b', 'isothermal', '898_120');

                elseif contains(deckname, 'pyopm')%pyopm deck
                    deckname = replace(deckname, 'pyopm-', '');
                    folderFromSrc = fullfile('pyopmcsp11\decks\',simcase.SPEcase, deckname, 'preprocessing');
                    deckname = 'CSP11A.DATA';
                    
                elseif strcmp(simcase.SPEcase, 'A')%deck from spe11-utils
                    deckname = ['CSP11A_', deckname, '.DATA'];
                    if ~isempty(deckname)
                        folderFromSrc = "spe11-utils\deck";
                    end
                    deckFolder = fullfile(simcase.spe11utilsDir, 'deck');
                elseif strcmp(simcase.SPEcase, 'B')
                    deckname = ['CSP11B_', deckname, '.DATA'];
                    deckFolder = fullfile(simcase.repoDir, 'deck');
                end
              
                % if isempty(deckFolder)%something wrong with config if we
                % enter here %TODO delete
                %     if strcmp(simcase.user, 'kholme')%on markov
                %         deckFolder = fullfile('/home/shomec/k/kholme/Documents/Prosjektoppgave/src/', replace(folderFromSrc, '\', '/'));
                %     else
                %         deckFolder = folderFromSrc;
                %     end
                % end
                %load deck from mat file or save to mat file
                decksavename = replace(deckname, '.DATA', '_deck.mat');
                decksaveFolder = simcase.decksaveDir;
                saveDeck = true;
                if isempty(decksaveFolder)
                    saveDeck = false;
                end
                decksavePath = fullfile(decksaveFolder, decksavename);
                if isfile(decksavePath)
                    disp('Loading deck from saved .mat file...')
                    load(decksavePath);
                else
                    disp('Converting deck...')
                    tic()
                    filename = fullfile(deckFolder, deckname);
                    deck = readEclipseDeck(filename);
                    deck = convertDeckUnits(deck);
                    if ~isfield(deck.GRID, 'ACTNUM')
                        deck.GRID.ACTNUM = deck.GRID.PORO > 0;
                    end
                    if saveDeck
                        disp('Saving deck...');
                        save(decksavePath, 'deck');
                    end
                    t1 = toc();
                    disp(['Done with deck setup in ', num2str(t1), 's'])
                end
                simcase.deck = deck;
            end
        end
        function fluid = get.fluid(simcase)
            fluid = simcase.fluid;
            if isempty(fluid)
                fluid = setupFluid(simcase);
                simcase.fluid = fluid;
            end
        end
        function rock = get.rock(simcase)
            rock = simcase.rock;
            if isempty(rock)  
                rock = setupRock(simcase);
                simcase.rock = rock;
            end
        end

        function user = get.user(simcase)
            user = simcase.user;
            if isempty(user)
                user = getenv('USER');  % For Unix/Linux/Mac
                if isempty(user)
                    user = getenv('USERNAME');  % For Windows
                end
                simcase.user = user;
            end

        end
        function G = get.G(simcase)
            G = simcase.G;
            if isempty(G)
                G = setupGrid(simcase);
                simcase.G = G;
            end
        end
        function model = get.model(simcase, varargin)
            model = simcase.model;
            if isempty(simcase.model) && simcase.updateprop
                model = setupModel(simcase, varargin{:});
                simcase.model = model;
            end
            
        end
        function [states, wellsols, reports] = getSimData(simcase)
            dataOutputDir = simcase.dataOutputDir;
            casename = simcase.casename;
            dirname = fullfile(dataOutputDir, casename); %casename was basename
            if simcase.jutul
                dirname =[dirname, '_output_mrst'];
                dataFolder = '';
            else
                dataFolder = 'multiphase';
            end
            contents = dir(fullfile(dirname, dataFolder));
            
            % Filter out any hidden files or folders (like . and .. on Unix-based systems)
            contents = contents(~ismember({contents.name}, {'.', '..'}));

            states = ResultHandler('dataPrefix', 'state', ...
                                   'dataDirectory', dirname, ...
                                   'dataFolder', dataFolder);
            wellsols = ResultHandler('dataPrefix', 'wellsols', ...
                                   'dataDirectory', dirname, ...
                                   'dataFolder', dataFolder);
            reports = ResultHandler('dataPrefix', 'report', ...
                                   'dataDirectory', dirname, ...
                                   'dataFolder', dataFolder);
        end

        function plotStates(simcase, varargin)
            opt = struct('field', 'rs', ...
                'pauseTime', 0.04);
            [opt, extra] = merge_options(opt, varargin{:});

            [states, ~, ~] = simcase.getSimData;
            figure
            plotToolbar(simcase.model.G, states, 'field', opt.field, 'pauseTime', opt.pauseTime, ...
                varargin{:});
            [inj1, inj2] = simcase.getinjcells;
            plotGrid(simcase.G, [inj1, inj2], 'faceAlpha', 0)
            if simcase.griddim==3
                view(0,0);
            end
            axis tight;
            if strcmp(simcase.SPEcase, 'A')
                axis equal;
            end
            colorbar;
            title(simcase.casename, 'Interpreter','none');
        end

        function plotFlux(simcase, varargin)
            opt = struct('direction', [], ...
                         'phase', 'g', ...
                         'pauseTime', 0.04);
            opt = merge_options(opt, varargin{:});

            [states, ~, ~] = simcase.getSimData;
            G = simcase.G;
            numsteps = numel(simcase.schedule.step.val);
            cv = cell(1, numsteps);
            for step = 1:numsteps
                cv{step} = CellVelocity(states, step, G, opt.phase, 'direction', opt.direction);
            end
            figure
            plotToolbar(G, cv, 'pauseTime', opt.pauseTime);
             [inj1, inj2] = simcase.getinjcells;
            plotGrid(simcase.G, [inj1, inj2], 'faceAlpha', 0)
            if simcase.griddim==3
                view(0,0);
            end
            axis tight;axis equal;
            colorbar;
            title(simcase.casename, 'Interpreter','none');

        end

        function [err, errvect, fwerr] = computeStaticIndicator(simcase, varargin)
            opt = struct('resetData', false);
            opt = merge_options(opt, varargin{:});
            filename = fullfile(simcase.dataOutputDir, simcase.casename, 'staticIndicator.mat');
            if isfile(filename) && ~opt.resetData
                disp('Loading computed data...')
                load(filename);
            else
                tbls = setupTables(simcase.G);
                [err, errvect, fwerr] = computeOrthError(simcase.G, simcase.rock, tbls);
                save(filename, 'err', 'errvect', 'fwerr');
            end
        end
        function errstruct = errStats(simcase, varargin)
            opt = struct('errType', 'err');
            [opt, extra] = merge_options(opt, varargin{:});
            [err, ~, fwerr] = simcase.computeStaticIndicator(extra{:});
            errstruct = struct('err', err, 'fwerr', fwerr);
            types = {'err', 'fwerr'};
            for et = 1:2
                type = types{et};
                errstruct.([type, 'Stats']).max = max(errstruct.(type));
                errstruct.([type, 'Stats']).mean = mean(errstruct.(type));
                errstruct.([type, 'Stats']).median = median(errstruct.(type));
                errstruct.([type, 'Stats']).norm = norm(errstruct.(type));
                errstruct.([type, 'Stats']).sum = sum(errstruct.(type));
            end
        end

        function plotErr(simcase, varargin)
            opt = struct('showStats', true, ...
                'errType', 'err', ...
                'plotHistogram', false);
            [opt, extra] = merge_options(opt, varargin{:});
            errstruct = simcase.errStats(extra{:});
           
            if opt.showStats
                fprintf('Grid: %s. Errortype: %s\n', simcase.gridcase, opt.errType);
                fprintf('\tMax error: %0.2e\n', errstruct.([opt.errType, 'Stats']).max);
                fprintf('\tMean error: %0.2e\n', errstruct.([opt.errType, 'Stats']).mean);
                fprintf('\tMedian error: %0.2e\n', errstruct.([opt.errType, 'Stats']).median);
                fprintf('\tNorm of error: %0.2e\n', errstruct.([opt.errType, 'Stats']).norm);
                fprintf('\tSum of error: %0.2e\n', errstruct.([opt.errType, 'Stats']).sum);
            end
            if opt.plotHistogram
                figure
                histogram(log10(errstruct.(opt.errType)));
                title(sprintf('%s', displayNameGrid(simcase.gridcase, simcase.SPEcase)));
                xlabel(sprintf('Log10(%s)', opt.errType));
                grid;
                ylabel('Frequency');
            end

            figure
            plotToolbar(simcase.G, errstruct);
            title(displayNameGrid(simcase.gridcase, simcase.SPEcase));
            view(0,0);
            axis tight;
            colorbar;
        end

        function [well1Index, well2Index] = getinjcells(simcase)
            SPEcase = simcase.SPEcase;
            G = simcase.G;
            [well1Index, well2Index] = getinjcells(G, SPEcase);
        end

        function popCells = getPoPCells(simcase)
            specase = simcase.SPEcase;
            switch specase
                case 'A'
                    pop1 = [1.5, 0.005, 1.2 - 0.5];
                    pop2 = [1.7, 0.005, 1.2 - 1.1];
                    popCells = findEnclosingCell(simcase.G, [pop1;pop2]);
                case 'B'
                    pop1 = [4500, 0.5, 1200 - 500];
                    pop2 = [5100, 0.5, 1200 - 1100];
                    popCells = findEnclosingCell(simcase.G, [pop1;pop2]);
            end
        end
        function wallTime = getWallTime(simcase)
            [~, ~, reports] = simcase.getSimData;
            wallTime = 0;
            reports.data;
            for i=1:numelData(reports)
                wallTime = wallTime + reports{i}.WallTime;
            end
        end

        function data = getCellData(simcase, type, varargin)
            opt = struct('cellIx', []);
            opt = merge_options(opt, varargin{:});
            cellIx = opt.cellIx;

            typeParts = strsplit(type, '.');

            if isempty(simcase.schedulecase) || strcmp(simcase.schedulecase, 'simple-std')
                steps = size(simcase.schedule.step.val, 1);
            end
            [states, ~, ~] = simcase.getSimData;
            steps = min(steps, numelData(states));
            data = NaN(steps, 1);
            if strcmp(type, 'pressure') || strcmp(type, 'rs') %variable has single value
                for it = 1:steps
                    fulldata = getfield(states{it}, typeParts{:});
                    data(it) = fulldata(cellIx);
                end
            elseif strcmp(type, 'Density') %report for water
                for it = 1:steps
                    fulldata = getfield(states{it}, typeParts{:});
                    data(it) = fulldata{1}(cellIx);
                end
            else %varable is reported for phase 2
                for it = 1:steps
                    fulldata = getfield(states{it}, typeParts{:});
                    if ~isempty(cellIx)%specific cell
                        data(it) = fulldata{2}(cellIx);
                    else %sum all values (for CTM)
                        data(it) = sum(fulldata{2});
                    end
                end
            end
        end 

        function saveGridRock(simcase, name)
            folder = 'grid-files/gridrock_simready';
            dispif(isempty(simcase.tagcase), 'No tag! Will remove facies 7 cells!\n');
            if ~isfield(simcase.G.cells, 'topCells')
                simcase = addTopBotTags(simcase);
            end
            G = simcase.G;
            rock = simcase.rock;
            G.bufferMult = rock.bufferMult;
            
            save(fullfile(folder, name), "rock", "G");
        end
    end
end