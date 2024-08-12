function y = softmax(x, temperature)
    % Applying the softmax function to each column of matrix x with a temperature parameter
    % x: A matrix where softmax is applied to each column.
    % temperature: A scalar that adjusts the smoothness of the softmax distribution.
    % y: A matrix where each column is the softmax of the corresponding column of x.

    if nargin < 2
        temperature = 1; % Default temperature if not specified
    end

    % Adjusting x by the temperature
    x_adjusted = x / temperature;

    % Subtract max for numerical stability
    exp_x = exp(x_adjusted - max(x_adjusted, [], 1));
    y = exp_x ./ sum(exp_x, 1);
end
