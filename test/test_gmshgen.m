% Test script for generateQTorTGridMatlab
clear all;
close all;

%% Test setup
tests = {
    struct('name', 'SPE11A QT grid', ...
           'params', struct('refinementFactor', 2.3, 'gridType', 'QT', 'SPEcase', 'A')), ...
    struct('name', 'SPE11A T grid', ...
           'params', struct('refinementFactor', 2.3, 'gridType', 'T', 'SPEcase', 'A')), ...
    struct('name', 'SPE11B QT grid', ...
           'params', struct('refinementFactor', 2.3, 'gridType', 'QT', 'SPEcase', 'B')), ...
    struct('name', 'SPE11B T grid', ...
           'params', struct('refinementFactor', 2.3, 'gridType', 'T', 'SPEcase', 'B')), ...
    struct('name', 'SPE11C QT grid', ...
           'params', struct('refinementFactor', 2.3, 'gridType', 'QT', 'SPEcase', 'C', 'Cdepth', 50)), ...
    struct('name', 'SPE11C T grid', ...
           'params', struct('refinementFactor', 2.3, 'gridType', 'T', 'SPEcase', 'C', 'Cdepth', 50)),...
   struct('name', 'SPE11B QT grid', ...
           'params', struct('refinementFactor', 3.39, 'gridType', 'QT', 'SPEcase', 'B')), ...
};
pythonpath = fullfile("scripts/gridgeneration/ggvenv/bin/python");

% Add environment setup
% if ispc
%     envpath = fullfile("scripts/gridgeneration/ggvenv/Scripts");
% else
%     envpath = fullfile("scripts/gridgeneration/ggvenv/bin");
% end
% setenv('PATH', [getenv('PATH') pathsep char(envpath)]);

%% Add after pythonpath definition
disp(['Python path: ' char(pythonpath)])
disp(['PATH: ' getenv('PATH')])
% system([char(pythonpath) ' -c "import gmsh; print(gmsh.__file__)"'])

%% Run tests
for i = 1:numel(tests)
    test = tests{i};
    fprintf('\nRunning test: %s\n', test.name);
    
    try
        % Convert struct to key-value pairs
        params = test.params;
        paramFields = fieldnames(params);
        paramArgs = cell(1, 2*numel(paramFields));
        for j = 1:numel(paramFields)
            paramArgs{2*j-1} = paramFields{j};
            paramArgs{2*j} = params.(paramFields{j});
        end
        
        % Call function with unpacked parameters
        G = generateQTorTGridMatlab(paramArgs{:}, 'pythonpath', char(pythonpath));
        
        % Basic grid validation
        assert(isfield(G, 'nodes'), 'Grid missing nodes field');
        assert(isfield(G, 'cells'), 'Grid missing cells field');
        assert(isfield(G, 'faces'), 'Grid missing faces field');
        
        % Case-specific validation
        switch test.params.SPEcase
            case 'A'
                % Check scaling for case A
                assert(max(G.nodes.coords(:,1)) < 3, 'Wrong X scaling for SPE11A');
                assert(max(G.nodes.coords(:,3)) < 2, 'Wrong Y scaling for SPE11A');
                
            case 'B'
                % Check scaling for case B
                assert(max(G.nodes.coords(:,1)) > 1000, 'Wrong X scaling for SPE11B');
                assert(max(G.nodes.coords(:,3)) > 500, 'Wrong Y scaling for SPE11B');
                
            case 'C'
                % Check 3D properties for case C
                assert(G.griddim == 3, 'SPE11C grid should be 3D');
                assert(size(G.nodes.coords, 2) == 3, 'SPE11C should have 3D coordinates');
                
        end
        
        fprintf('✓ Test passed: %s\n', test.name);
        
    catch ME
        fprintf('✗ Test failed: %s\n', test.name);
        fprintf('Error: %s\n', ME.message);
    end
end