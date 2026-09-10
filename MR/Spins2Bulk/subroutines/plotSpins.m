function plotSpins(Spins, M)
% Draw the individual spins and the bulk magnetization vector they sum to.
%
%   plotSpins(Spins, M)
%
% Spins is nspins x 3 and M is the 1 x 3 bulk magnetization, in units of the
% equilibrium magnetization.
%
% The graphics objects are built once and then updated in place on later
% calls. Rebuilding a scatter of several thousand points every frame is by
% far the slowest part of the animation, so this is what keeps it smooth.

ax = gca;
ud = ax.UserData;

if isstruct(ud) && isfield(ud, 'spins') && all(isvalid([ud.spins ud.total]))

    set(ud.spins, 'XData', Spins(:,1), 'YData', Spins(:,2), 'ZData', Spins(:,3));
    set(ud.total, 'XData', [0 M(1)], 'YData', [0 M(2)], 'ZData', [0 M(3)]);
    set(ud.trans, 'XData', [0 M(1)], 'YData', [0 M(2)], 'ZData', [0 0]);
    set(ud.longi, 'XData', [0 0],    'YData', [0 0],    'ZData', [0 M(3)]);

else

    ud = struct();

    % Individual spin vectors
    ud.spins = scatter3(ax, Spins(:,1), Spins(:,2), Spins(:,3), 100, '.', ...
        'MarkerFaceColor', .2*[1 1 1], 'MarkerFaceAlpha', .8, ...
        'MarkerEdgeColor', .2*[1 1 1], 'MarkerEdgeAlpha', .8);

    hold(ax, 'on');
    plotAxes(ax);

    % Bulk magnetization: total, transverse component, longitudinal component
    ud.total = plot3(ax, [0 M(1)], [0 M(2)], [0 M(3)], 'k-', 'LineWidth', 4);
    ud.trans = plot3(ax, [0 M(1)], [0 M(2)], [0 0],    'r-', 'LineWidth', 4);
    ud.longi = plot3(ax, [0 0],    [0 0],    [0 M(3)], 'g-', 'LineWidth', 4);
    hold(ax, 'off');

    axis(ax, [-1 1 -1 1 -1 1]);
    axis(ax, 'square');
    xlabel(ax, 'X'); ylabel(ax, 'Y'); zlabel(ax, 'Z');
    set(ax, 'FontSize', 16, 'View', [-10 15]);

    ax.UserData = ud;

end

end
