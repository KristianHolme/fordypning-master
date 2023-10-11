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
        discmethod %eks. 'hybrid-avgmpfa-oo'

        G
        rock
        fluid
        schedule
        model
        user
        dataOutputDir
        deck
        
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
                         'discmethod'   , []);
            opt = merge_options(opt, varargin{:});

            propnames = {'SPEcase', 'deckcase', 'gridcase', 'discmethod', 'fluidcase', 'tagcase',...
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



            simcase.updateprop = true;
            simcase.resetprop  = true;
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
            casename = replace(casename, 'SPE=', 'SPE');
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

        function simcase = set.discmethod(simcase, discmethod)
            simcase.discmethod = discmethod;
            if simcase.updateprop
                simcase.casename = simcase.ConstructCasename();
                simcase.resetProps;
            end
        end


        function schedule = get.schedule(simcase)
            schedule = simcase.schedule;
            if isempty(schedule)
                schedule = setupSchedule11A(simcase);
                simcase.schedule = schedule;
            end
        end

        function deck = get.deck(simcase)
            deck = simcase.deck;
            if isempty(deck)
                deckname = simcase.deckcase;
                deckname = ['CSP11A_', deckname, '.DATA'];
                if ~isempty(deckname)
                    if strcmp(simcase.user, 'kholme')
                        deckFolder = '/home/shomec/k/kholme/Documents/Prosjektoppgave/src/spe11-utils/deck';
                    else
                        deckFolder = "spe11-utils\deck";
                    end
                    deck = readEclipseDeck(fullfile(deckFolder, deckname));
                    deck = convertDeckUnits(deck);
                end
                simcase.deck = deck;
            end
        end
        function fluid = get.fluid(simcase)
            fluid = simcase.fluid;
            if isempty(fluid)
                fluid = setupFluid11A(simcase);
                simcase.fluid = fluid;
            end
        end
        function rock = get.rock(simcase)
            rock = simcase.rock;
            if isempty(rock)  
                rock = setupRock11A(simcase);
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
                G = setupGrid11A(simcase);
                simcase.G = G;
            end
        end
        function model = get.model(simcase)
            model = simcase.model;
            if isempty(simcase.model) && simcase.updateprop
                model = setupModel11A(simcase);
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
        function dataOutputDir = get.dataOutputDir(simcase)
            dataOutputDir = simcase.dataOutputDir;
            if isempty(dataOutputDir)
                if strcmp(simcase.user, 'holme')
                    dataOutputDir = 'C:\Users\holme\OneDrive\Dokumenter\_Studier\Prosjekt\Prosjektoppgave\src\output';
                elseif strcmp(simcase.user, 'kholme')
                    dataOutputDir = '/home/shomec/k/kholme/Documents/Prosjektoppgave/src/output';
                end
                simcase.dataOutputDir = dataOutputDir;
            end
        end
        function plotStates(simcase)
            [states, wellsols, reports] = simcase.getSimData;
            figure
            plotToolbar(simcase.G, states, 'field', 'FlowProps.ComponentTotalMass:2', 'pauseTime', 0.05);
            view(0,0);
            axis tight;
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
                    well1Coords = [0.9, 0.05, 1.2-0.3];
                    well2Coords = [1.7, 0.05, 1.2-0.7];
                else
                    well1Coords = [0.9, 0.3];
                    well2Coords = [1.7, 0.7];
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
            end
        end

        function data = getCellData(simcase, type, cellIx)
            typeParts = strsplit(type, '.');

            if isempty(simcase.schedulecase) || strcmp(simcase.schedulecase, 'simple-std')
                steps = 720;
            end
            [states, ~, ~] = simcase.getSimData;
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
                    data(it) = fulldata{2}(cellIx);
                end
            end
        end     
    end
end