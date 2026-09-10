function plotBulk(t, M)
% Plot the longitudinal and transverse magnetization against time.
%
%   plotBulk(t, M)
%
% t is the full time vector and M is the history so far, nsteps_so_far x 3.
% Two line objects are created once and then updated, rather than adding a
% new segment per frame.

ax = gca;
n  = size(M,1);

Mz  = M(:,3);
Mxy = vecnorm(M(:,1:2), 2, 2);

ud = ax.UserData;

if isstruct(ud) && isfield(ud, 'mz') && all(isvalid([ud.mz ud.mxy]))

    set(ud.mz,  'XData', t(1:n), 'YData', Mz);
    set(ud.mxy, 'XData', t(1:n), 'YData', Mxy);

else

    ud = struct();
    ud.mz = plot(ax, t(1:n), Mz, 'g.-');
    hold(ax, 'on');
    ud.mxy = plot(ax, t(1:n), Mxy, 'r.-');
    hold(ax, 'off');

    axis(ax, [0 max(t) -1 1.1]);
    axis(ax, 'square');
    xlabel(ax, 'Time (s)');
    ylabel(ax, 'Magnetization');
    legend(ax, {'Mz', 'Mxy'}, 'AutoUpdate', 'off', 'Location', 'southwest');

    ax.UserData = ud;

end

end
