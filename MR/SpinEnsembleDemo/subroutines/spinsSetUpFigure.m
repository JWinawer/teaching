function layout = spinsSetUpFigure(figureHandle, titleText)
% Prepare the figure and tiled layout used by spinsAnimate.
%
%   layout = spinsSetUpFigure(figureHandle, titleText)
%
% Clears the figure, sets its size, and returns a 3 x 4 tiled layout with the
% given title.
%
% See also spinsAnimate

clf(figureHandle);

% Parent the layout to the figure explicitly. clf does not make a figure
% current, so a bare tiledlayout would land in whatever figure was current.
layout = tiledlayout(figureHandle, 3, 4);

figureSize = [800 600];   % pixels
figureHandle.Position(3:4) = figureSize;

title(layout, titleText, FontSize=18);

end
