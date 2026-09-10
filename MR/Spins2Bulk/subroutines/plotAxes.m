function plotAxes(ax)
% Draw the three coordinate axes through the origin.

if ~exist('ax', 'var') || isempty(ax), ax = gca; end

plot3(ax, [-1 1], [0 0], [0 0], 'k-');
plot3(ax, [0 0], [1 -1], [0 0], 'k-');
plot3(ax, [0 0], [0 0], [-1 1], 'k-');

end
