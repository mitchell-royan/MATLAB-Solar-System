function [p, v, trajectories] = solarsystem(p, v, mass, stop_time, hide_animation)
% SOLARSYSTEM Simulate the motion of celestial bodies in the solar system.
%
% [p, v, trajectories] = SOLARSYSTEM(p, v, mass, stop_time, hide_animation) simulates the
% motion of celestial bodies given their initial positions, velocities, masses,
% and the duration of the simulation. The optional hide_animation parameter
% can be used to hide the animation (not used in this function).
%
% Inputs:
%   - p: Initial positions of celestial bodies (Nx2 or Nx3 matrix)
%   - v: Initial velocities of celestial bodies (Nx2 or Nx3 matrix)
%   - mass: Masses of celestial bodies (Nx1 vector)
%   - stop_time: Duration of simulation (scalar, in seconds)
%   - hide_animation: Flag to hide animation (not used in this function, default: false)
%
% Outputs:
%   - p: Final positions of celestial bodies (Nx2 or Nx3 matrix)
%   - v: Final velocities of celestial bodies (Nx2 or Nx3 matrix)
%   - trajectories: Cell array containing trajectories of each celestial body

% Set default value for hide_animation if not provided
if nargin < 5
    hide_animation = false;
end

% Gravitational constant (Nm^2/kg^2)
G = 6.67430e-11; % Updated gravitational constant for increased precision

% Simulation timestep (s)
dt = 1000; % Change timestep for improved accuracy

% Trajectory update interval
trajectory_update_interval = 100; % Update trajectories every 100 timesteps

% Determine dimensionality
is_3D = size(p, 2) == 3;

% Initialize the figure for animation
if ~hide_animation
    figure;
    hold on;
    set(gcf, 'Color', 'black');  % Set background color to black
    set(gca, 'Color', 'black');   % Set plot background color to black
    xlabel('x-position (m)', 'Color', 'white');
    ylabel('y-position (m)', 'Color', 'white');
    if is_3D
        zlabel('z-position (m)', 'Color', 'white'); % Add z-label for 3D plot
    end
    title('Simulation of Celestial Bodies in the Solar System', 'Color', 'white');
    grid on;
    
    % Set axis lines and ticks color to white
    ax = gca;
    ax.XAxis.Color = 'white';
    ax.YAxis.Color = 'white';
    if is_3D
        ax.ZAxis.Color = 'white';
    end
    ax.GridColor = 'white';

    % Set specific colors for Sun and Earth
    sun_color = [1 1 0];  % Yellow
    earth_color = [0 0 1]; % Blue
    
    % Generate colors for additional bodies
    num_additional_bodies = size(p, 1) - 2; % Subtract Sun and Earth
    additional_colors = rand(num_additional_bodies, 3); % Random colors
    
    % Combine colors
    colors = [sun_color; earth_color; additional_colors];
    
    % Define sizes for Sun and Earth
    sizes = [20; 12; rand(num_additional_bodies, 1) * 10 + 5]; % Random sizes for additional bodies
    
    % Plot the celestial bodies
    planets_handle = gobjects(size(p, 1), 1);
    for i = 1:size(p, 1)
        if is_3D
            planets_handle(i) = plot3(p(i, 1), p(i, 2), p(i, 3), 'o', 'MarkerSize', sizes(i), 'MarkerFaceColor', colors(i,:), 'MarkerEdgeColor', 'none');
        else
            planets_handle(i) = plot(p(i, 1), p(i, 2), 'o', 'MarkerSize', sizes(i), 'MarkerFaceColor', colors(i,:), 'MarkerEdgeColor', 'none');
        end
    end

    % Set axis limits 
    if is_3D
        axis([-2.5e11 2.5e11 -2.5e11 2.5e11 -2.5e11 2.5e11]);
    else
        axis([-2.5e11 2.5e11 -2.5e11 2.5e11]);
    end

    % Set initial view
    if is_3D
        view(50, 15);
    end
end

% Number of celestial bodies
num_bodies = size(p, 1);

% Initialize trajectories
trajectories = cell(num_bodies, 1);

% Simulation loop
for t = 1:stop_time/dt
    % Initialize accelerations
    a = zeros(size(p));

    % Calculate gravitational forces
    for i = 1:num_bodies
        for j = 1:num_bodies
            if i ~= j
                % Calculate distance vector
                r = p(j, :) - p(i, :);
                % Calculate gravitational force
                F = G * mass(i) * mass(j) / norm(r)^2 * (r / norm(r)); 
                % Update acceleration
                a(i, :) = a(i, :) + F / mass(i);
            end
        end
    end

    % Update velocities
    v = v + a * dt;

    % Update positions
    p = p + v * dt;

    % Record trajectories
    if mod(t, trajectory_update_interval) == 0
        for i = 1:num_bodies
            trajectories{i} = [trajectories{i}; p(i, :)];
        end
    end

    % Update the plot
    if ~hide_animation
        % Update all bodies' positions
        for i = 1:num_bodies
            if is_3D
                set(planets_handle(i), 'XData', p(i, 1), 'YData', p(i, 2), 'ZData', p(i, 3));
            else
                set(planets_handle(i), 'XData', p(i, 1), 'YData', p(i, 2));
            end
        end
        
        % Plot trajectories
        for i = 1:num_bodies
            if mod(t, trajectory_update_interval) == 0
                if is_3D
                    plot3(trajectories{i}(:, 1), trajectories{i}(:, 2), trajectories{i}(:, 3), 'Color', colors(i,:));
                else
                    plot(trajectories{i}(:, 1), trajectories{i}(:, 2), 'Color', colors(i,:));
                end
            end
        end

        % Trigger screen refresh
        drawnow limitrate;
    end
end

end
