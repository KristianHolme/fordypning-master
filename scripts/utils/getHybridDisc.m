function hybridModel = getHybridDisc(simcase, tpfaModel, hybridDiscmethod, cellblocks, varargin)
    opt = struct('resetAssembly', false, ...
        'ratio', []);
    [opt, extra] = merge_options(opt, varargin{:});

    resetAssembly = opt.resetAssembly;
    G = simcase.G;
    rock = simcase.rock;


    models = cell(1, 2);
    models{1} = tpfaModel;
    assemblyDir = fullfile(simcase.dataOutputDir, 'assembly', simcase.gridcase, hybridDiscmethod);
    switch hybridDiscmethod
        case 'avgmpfa-oo'
            structFileName = 'avgmpfaoostruct.mat';
        case 'ntpfa-oo'
            structFileName = 'ntpfaoostruct.mat';
        case 'mpfa-oo'
            structFileName = '';
            %not saved
    end
    structFilePath = fullfile(assemblyDir, structFileName);

    
    switch hybridDiscmethod
        case 'avgmpfa-oo'
            if isfile(structFilePath) && ~resetAssembly
                load(structFilePath);
            else
                hybridAssemblyStruct.interpFace = findHAP(G, rock);
                hybridAssemblyStruct.interpFace = correctHAP(G, hybridAssemblyStruct.interpFace, opt.ratio);
                hybridAssemblyStruct.OSflux = findOSflux(G, rock, hybridAssemblyStruct.interpFace);

                saveStruct(hybridAssemblyStruct, assemblyDir, structFileName);
            end
            model = setAvgMPFADiscretization(tpfaModel, 'OSflux', hybridAssemblyStruct.OSflux, ...
                    'interpFace', hybridAssemblyStruct.interpFace);
            models{2} = model;
        case 'ntpfa-oo'
            if isfile(structFilePath) && ~resetAssembly
                load(structFilePath);
            else
                hybridAssemblyStruct.interpFace = findHAP(G, rock);
                hybridAssemblyStruct.interpFace = correctHAP(G, hybridAssemblyStruct.interpFace, opt.ratio);
                hybridAssemblyStruct.OSflux = findOSflux(G, rock, hybridAssemblyStruct.interpFace);

                saveStruct(hybridAssemblyStruct, assemblyDir, structFileName);
            end
            model = setNTPFADiscretization(tpfaModel, 'OSflux', hybridAssemblyStruct.OSflux, ...
                    'interpFace', hybridAssemblyStruct.interpFace);
            models{2} = model;
        case 'mpfa-oo'
            model = setMPFADiscretization(tpfaModel);
            models{2} = model;
    end
    
    faceBlocks = getFaceBlocks(G, cellblocks, extra{:});%faces

    hybridModel = setHybridDiscretization(tpfaModel, models, faceBlocks);
end

function saveStruct(hybridAssemblyStruct, assemblyDir, structFileName)
    if ~exist(assemblyDir, 'dir')
        mkdir(assemblyDir);
    end
    save(fullfile(assemblyDir, structFileName), 'hybridAssemblyStruct');
end
    