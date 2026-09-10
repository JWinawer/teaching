function [fH, tH] = spinsSetUpFigure(fH, titlestr)
% Prepare the figure and tiled layout used by animateSpins.

clf(fH);

% Parent the layout to fH explicitly. clf does not make a figure current, so
% a bare tiledlayout would land in whatever figure happened to be current.
tH = tiledlayout(fH, 3, 4);

pos = get(fH, 'Position');
pos(3:4) = [800 600];
set(fH, 'Position', pos);

title(tH, titlestr, fontsize=18);

end
