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

        G
        rock
        fluid
        schedule
        model
        deck
        user
        dataOutputDir
        spe11utilsDir
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
                         'gridcase'     , [], ...
                         'fluidcase'    , [], ...
                         'tagcase'      , [], ...
                         'deckcase'     , [], ...
                         'usedeck'      , false, ...
                         'schedulecase' , [], ...
                         'deck'         , [], ...
                         'rockcase'     , [], ...
                         'pdisc'   , '', ...
                         'griddim'      , 3, ...
                         'uwdisc'      , []);
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
            
            %configure folder structure
            configFile = fileread('config.JSON');
            config = jsondecode(configFile);
            simcase.dataOutputDir = config.output_folder;
            simcase.spe11utilsDir = config.spe11utils_folder;
            simcase.decksaveDir = config.decksave_folder;
            simcase.repoDir = config.repo_folder;

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
                if contains(deckname, 'pyopm')%pyopm deck
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
                if isempty(decksaveFolder)
                    decksaveFolder = deckFolder;
                end
                decksavePath = fullfile(decksaveFolder, decksavename);
                if isfile(decksavePath)
                    disp('Loading deck from saved .mat file...')
                    load(decksavePath);
                else
                    disp('Reading, converting and saving deck...')
                    tic()
                    filename = fullfile(deckFolder, deckname);
                    deck = readEclipseDeck(filename);
                    deck = convertDeckUnits(deck);
                    if ~isfield(deck.GRID, 'ACTNUM')
                        deck.GRID.ACTNUM = deck.GRID.PORO > 0;
                    end
                    save(decksavePath, 'deck');
                    t1 = toc();
                    disp(['Done in ', num2str(t1), 's'])
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
            states = ResultHandler('dataPrefix', 'state', ...
                                   'dataDirectory', dirname, ...
                                   'dataFolder', 'multiphase');
            wellsols = ResultHandler('dataPrefix', 'wellsols', ...
                                   'dataDirectory', dirname, ...
                                   'dataFolder', 'multiphase');
            reports = ResultHandler('dataPrefix', 'report', ...
                                   'dataDirectory', dirname, ...
                                   'dataFolder', 'multiphase');
        end
        % function dataOutputDir = get.dataOutputDir(simcase) %TODO delete
        %     dataOutputDir = simcase.dataOutputDir;
        %     if isempty(dataOutputDir)%should not enter here if config is correct
        %         if strcmp(simcase.user, 'holme')
        %             dataOutputDir = 'C:\Users\holme\OneDrive\Dokumenter\_Studier\Prosjekt\Prosjektoppgave\src\output';
        %         elseif strcmp(simcase.user, 'kholme')%on markov
        %             dataOutputDir = '/home/shomec/k/kholme/Documents/Prosjektoppgave/src/output';
        %         end
        %         simcase.dataOutputDir = dataOutputDir;
        %     end
        % end
        function plotStates(simcase, varargin)
            opt = struct('field', 'rs', ...4
                'pauseTime', 0.05);
            [opt, extra] = merge_options(opt, varargin{:});

            [states, ~, ~] = simcase.getSimData;
            figure
            plotToolbar(simcase.G, states, 'field', opt.field, 'pauseTime', opt.pauseTime, ...
                varargin{:});
            [inj1, inj2] = simcase.getinjcells;
            plotGrid(simcase.G, [inj1, inj2], 'faceAlpha', 0)
            if simcase.griddim==3
                view(0,0);
            end
            axis tight;axis equal;
            colorbar;
            title(simcase.casename, 'Interpreter','none');
        end
        function [err, errvect, fwerr] = computeStaticIndicator(simcase)
            tbls = setupTables(simcase.G);
            [err, errvect, fwerr] = computeOrthError(simcase.G, simcase.rock, tbls);
        end
        function [well1Index, well2Index] = getinjcells(simcase)
            SPEcase = simcase.SPEcase;
            G = simcase.G;
            if strcmp(SPEcase, 'A')
                [~, dim] = size(G.cells.centroids);
                if dim == 3
                    well1Coords = [0.9, 0.005, 1.2-0.3];
                    well2Coords = [1.7, 0.005, 1.2-0.7];
                else
                    well1Coords = [0.9, 0.3];
                    well2Coords = [1.7, 0.7];
                end
                [~,well1Index] = min(vecnorm(G.cells.centroids - well1Coords, 2, 2));
                [~,well2Index] = min(vecnorm(G.cells.centroids - well2Coords, 2, 2));
            elseif strcmp(SPEcase, 'B')
                [~, dim] = size(G.cells.centroids);
                if dim == 3
                    well1Coords = [2700, 0.5, 1200-300];
                    well2Coords = [5100, 0.5, 1200-700];
                else
                    well1Coords = [2700, 300];
                    well2Coords = [5100, 700];
                end
                [~,well1Index] = min(vecnorm(G.cells.centroids - well1Coords, 2, 2));
                [~,well2Index] = min(vecnorm(G.cells.centroids - well2Coords, 2, 2));

            end
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
            data = zeros(steps, 1);
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
    end
end