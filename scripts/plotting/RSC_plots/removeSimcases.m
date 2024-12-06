function simcases = removeSimcases(simcases, gridnames_to_remove, pdiscs_to_remove)
    % Remove simulation cases with specified grid names and discretizations
    %
    % Parameters:
    %   simcases (cell array): Array of simulation cases
    %   gridnames_to_remove (cell array): Grid names to remove (e.g., {'C', 'HC'})
    %   pdiscs_to_remove (cell array): Discretizations to remove (e.g., {'ntpfa', 'mpfa'})
    %
    % Returns:
    %   simcases (cell array): Filtered simulation cases
    
    % Initialize mask for cases to keep
    keep_mask = true(size(simcases));
    
    % Check each simcase
    for i = 1:numel(simcases)
        % Get grid type (remove numbers from gridcase name)
        gridname = gridcase_to_RSCname(simcases{i}.gridcase);
        
        % Get discretization type
        pdisc = simcases{i}.pdisc;
        
        % Mark for removal if grid or disc matches any in the removal lists
        if (any(strcmp(gridname, gridnames_to_remove)) && ...
            any(strcmp(pdisc, pdiscs_to_remove)))
            keep_mask(i) = false;
        end
    end
    
    % Keep only the cases that weren't marked for removal
    simcases = simcases(keep_mask);
end