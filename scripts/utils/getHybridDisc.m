function hybridModel = getHybridDisc(simcase, tpfaModel, hybridDiscmethod, cellblocks, varargin)
    opt = struct('resetAssembly', false, ...
        'myRatio', [], ...
        'saveAssembly', true);
    [opt, extra] = merge_options(opt, varargin{:});

    resetAssembly = opt.resetAssembly;
    G = simcase.G;
    rock = simcase.rock;


    models = cell(1, 2);
    models{1} = tpfaModel;
    assemblyDir = fullfile(simcase.dataOutputDir, 'assembly', simcase.gridcase, hybridDiscmethod);
    switch hybridDiscmethod
        case 'avgmpfa'
            structFileName = 'avgmpfastruct.mat';
        case 'ntpfa'
            structFileName = 'ntpfastruct.mat';
        case 'mpfa'
            structFileName = '';
            %not saved
    end
    structFilePath = fullfile(assemblyDir, structFileName);

    mv = mrstVerbose;
    mrstVerbose on;
    switch hybridDiscmethod
        case 'avgmpfa'
            if isfile(structFilePath) && ~resetAssembly
                load(structFilePath);
            else
                hybridAssemblyStruct.interpFace = findHAP(G, rock);
                hybridAssemblyStruct.interpFace = correctHAP(G, hybridAssemblyStruct.interpFace, opt.myRatio);
                hybridAssemblyStruct.OSflux = findOSflux(G, rock, hybridAssemblyStruct.interpFace);
                if opt.saveAssembly
                    saveStruct(hybridAssemblyStruct, assemblyDir, structFileName);
                end
            end
            model = setAvgMPFADiscretization(tpfaModel, 'OSflux', hybridAssemblyStruct.OSflux, ...
                    'interpFace', hybridAssemblyStruct.interpFace);
            models{2} = model;
        case 'ntpfa'
            if isfile(structFilePath) && ~resetAssembly
                load(structFilePath);
            else
                hybridAssemblyStruct.interpFace = findHAP(G, rock);
                hybridAssemblyStruct.interpFace = correctHAP(G, hybridAssemblyStruct.interpFace, opt.myRatio);
                hybridAssemblyStruct.OSflux = findOSflux(G, rock, hybridAssemblyStruct.interpFace);
                if opt.saveAssembly
                    saveStruct(hybridAssemblyStruct, assemblyDir, structFileName);
                end
            end
            model = setNTPFADiscretization(tpfaModel, 'OSflux', hybridAssemblyStruct.OSflux, ...
                    'interpFace', hybridAssemblyStruct.interpFace);
            models{2} = model;
        case 'mpfa'
            model = setMPFADiscretization(tpfaModel);
            models{2} = model;
    end
    mrstVerbose(mv);
    
    faceBlocks = getFaceBlocks(G, cellblocks, extra{:});%faces

    hybridModel = setHybridDiscretization(tpfaModel, models, faceBlocks);
end

function saveStruct(hybridAssemblyStruct, assemblyDir, structFileName)
    if ~exist(assemblyDir, 'dir')
        mkdir(assemblyDir);
    end
    save(fullfile(assemblyDir, structFileName), 'hybridAssemblyStruct');
end
    