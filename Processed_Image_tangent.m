% --- Load the Stratification.fig file ---
figFile = 'Stratification.fig';  % 
openfig(figFile);             % Opens the Stratification.fig

% --- Extract data from the Stratification.fig file ---
% Assumes there's a single plot
h = findobj(gca, 'Type', 'line');
x = get(h, 'XData');
y = get(h, 'YData');

% --- Selecting points to draw tangent ---
disp('Select the points where you want to draw the tangent. Press Enter when done.');
[selectedX, selectedY] = ginput();  % code to collect the points by user selection 

hold on;

% --- Tangent plotting ---
for i = 1:length(selectedX)
    % Find nearest index on the curve
    [~, idx] = min((x - selectedX(i)).^2 + (y - selectedY(i)).^2);

    % Estimate slope (dy/dx) using central difference
    if idx == 1
        % Forward difference at start
        dx = x(idx+1) - x(idx);
        dy = y(idx+1) - y(idx);
    elseif idx == length(x)
        % Backward difference at end
        dx = x(idx) - x(idx-1);
        dy = y(idx) - y(idx-1);
    else
        % Central difference
        dx = x(idx+1) - x(idx-1);
        dy = y(idx+1) - y(idx-1);
    end

    slope = dy / dx;

    % Define tangent line parameters
    xRange = linspace(x(idx) - 1, x(idx) + 0.1, 100);  % Adjust the 1 for line length
    yTangent = slope * (xRange - x(idx)) + y(idx);

    % Plot tangent line
    plot(xRange, yTangent, 'r--', 'LineWidth', 1.5);

    % Mark selected point
    plot(x(idx), y(idx), 'ko', 'MarkerFaceColor', 'k');
    xHorLine = [x(idx), x(idx) + 1];  % Adjust line length if needed
    yHorLine = [y(idx), y(idx)];
    plot(xHorLine, yHorLine, 'b--', 'LineWidth', 1.2);  % Plots horizontal line through the tangent point
end
    if length(selectedX) >= 2
    % Use the first two points to calculate ΔY
    % Find nearest indices to selected points
    [~, idx1] = min((x - selectedX(1)).^2 + (y - selectedY(1)).^2);
    [~, idx2] = min((x - selectedX(2)).^2 + (y - selectedY(2)).^2);

    y1 = y(idx1);
    y2 = y(idx2);
    dy = y2 - y1;

    % Midpoint for displaying the text label
    midX = (x(idx1) + x(idx2)) / 2;
    midY = (y1 + y2) / 2;

    % Draw a vertical line between the two Y points
    plot([x(idx1), x(idx1)], [y1, y2], 'g-', 'LineWidth', 1.5);  % Vertical line at point 1

    % Display ΔY on the plot
    text(midX, midY, sprintf('\\Deltah = %.3f', dy), ...
        'Color', 'm', 'FontSize', 12, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'BackgroundColor', 'w');
else
    disp('At least two points are needed to calculate h-difference.');
    end
title('Tangents at Selected Points');
hold off;
