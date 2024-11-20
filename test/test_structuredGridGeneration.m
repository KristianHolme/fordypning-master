function tests = test_structuredGridGeneration
    tests = functiontests(localfunctions);
end

function setupOnce(testCase)
    % Store the current directory
    testCase.TestData.origDir = pwd();
    
    % Move up one directory from test folder
    [parentDir, ~, ~] = fileparts(pwd());
    cd(parentDir);
    
    % Add required modules
    mrstModule add spe11
end

function test_SPE11A_grid(testCase)
    nx = 60; ny = -1; nz = 30;
    
    G = generateStructuredGrid(nx, ny, nz, 'SPEcase', 'A', 'save', false, 'backgroundGridMap', false);

    % Verify grid integrity
    verifyTrue(testCase, checkGrid(G), 'Grid fails integrity check')
    
    % Basic grid property checks
    verifyEqual(testCase, G.cells.num, nx*nz, 'Number of cells mismatch')
    verifyTrue(testCase, isfield(G.faces, 'tag'), 'Missing faces.tag')
    
    % Verify dimensions roughly match SPE11-A (2.8m x 1.2m)
    coords = G.nodes.coords;
    approxDims = max(coords) - min(coords);
    verifyEqual(testCase, approxDims(1), 2.8, 'RelTol', 0.1, 'X dimension mismatch')
    verifyEqual(testCase, approxDims(3), 1.2, 'RelTol', 0.1, 'Z dimension mismatch')
end

function test_SPE11B_grid(testCase)
    nx = 60; ny = 30; nz = 12;
    G = generateStructuredGrid(nx, ny, nz, 'SPEcase', 'B', 'save', false, 'backgroundGridMap', true);

    % Verify grid integrity
    verifyTrue(testCase, checkGrid(G), 'Grid fails integrity check')
    
    % Verify dimensions roughly match SPE11-B
    coords = G.nodes.coords;
    approxDims = max(coords) - min(coords);
    verifyEqual(testCase, approxDims(1), 8400, 'RelTol', 0.1, 'X dimension mismatch')
    verifyEqual(testCase, approxDims(2), 1, 'RelTol', 0.1, 'Y dimension mismatch')
    verifyEqual(testCase, approxDims(3), 1200, 'RelTol', 0.1, 'Z dimension mismatch')
end

function test_SPE11C_grid(testCase)
    nx = 60; ny = 30; nz = 12;
    G = generateStructuredGrid(nx, ny, nz, 'SPEcase', 'C', 'save', false);

    % Verify grid integrity
    verifyTrue(testCase, checkGrid(G), 'Grid fails integrity check')
    
    % Verify dimensions roughly match SPE11-C (8400x5000x1200 m)
    coords = G.nodes.coords;
    approxDims = max(coords) - min(coords);
    verifyEqual(testCase, approxDims(1), 8400, 'RelTol', 0.1, 'X dimension mismatch')
    verifyEqual(testCase, approxDims(2), 5000, 'RelTol', 0.1, 'Y dimension mismatch')
end

function teardown(testCase)
    % Return to original directory
    %cd(testCase.TestData.origDir);
end