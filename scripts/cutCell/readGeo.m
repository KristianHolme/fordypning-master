function result = readGeo(filename)
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
end