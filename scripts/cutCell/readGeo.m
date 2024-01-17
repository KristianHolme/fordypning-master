function result = readGeo(filename, varargin)
    opt = struct('assignextra', false);
    opt = merge_options(opt, varargin{:});
    % Open the file
    if isempty(filename)
        configFile = fileread('config.JSON');
        config = jsondecode(configFile);
        filename = fullfile(config.geo_folder, 'spe11a.geo');
    end
    fid = fopen(filename, 'r');
    if fid == -1
        error('File cannot be opened: %s', filename);
    end
    text = fread(fid, '*char').';
    fclose(fid);

    % Updated regular expression to handle negative numbers
    data = regexp(text, '(\w+)\((-?\d+)\) = \{([\d., -]+)', 'tokens');
    data = vertcat(data{:});
    data(:,1) = strrep(data(:,1), ' ', '_');
    data(:,[2 3]) = cellfun(@(s) str2num(s), data(:,[2 3]), 'UniformOutput', false);

    args = unique(data(:,1)).';
    args(end+1,:) = {[]};
    result = struct(args{:});

    for ii = 1:size(data,1)
        fieldName = data{ii,1};
        index = data{ii,2};
        value = data{ii,3};

        if ~isfield(result, fieldName)
            result.(fieldName) = {};  % Initialize as an empty cell array
        end

        % Ensure the cell array is large enough
        if length(result.(fieldName)) < index
            result.(fieldName){index} = [];
        end

        % Assign the value
        result.(fieldName){index} = value;
    end

    %Read horizons if present
    datahorz = regexp(text, '\"([A-Za-z]\d*(\.\d+)?)\", \d+\) = \{([\d, ]+)\}', 'tokens');
    if ~isempty(datahorz)
        datahorz = vertcat(datahorz{:});
        datahorz(:,2) = cellfun(@(s) str2num(s), datahorz(:,2), 'UniformOutput', false);
        result.horizons = datahorz;
    end
    if opt.assignextra
    %assign loops to Fascies
        result.Facies{1} = [7, 8, 9, 32];
        result.Facies{7} = [1, 31];
        result.Facies{5} = [2, 3, 4, 5, 6];
        result.Facies{4} = [10, 11, 12, 13, 14, 15, 22];
        result.Facies{3} = [16, 17, 18, 19, 20, 21];
        result.Facies{6} = [23, 24, 25];
        result.Facies{2} = [26, 27, 28, 29, 30];
        result.BoundaryLines = unique([1, 2, 12, 11, 9, 8, 10, 7, 6, 5, 3, 4, 24, 23, 22, 21, 20, 19, 18, 17, 16, 14, 15, 13]);
    end
end