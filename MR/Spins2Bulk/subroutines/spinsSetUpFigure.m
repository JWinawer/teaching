function fH = spinsSetUpFigure(fH, titlestr)
clf(fH); tH = tiledlayout(3,4);
pos = get(fH, 'Position');
pos(3:4) = [800 600];
set(gcf, 'Position', pos);
title(tH, titlestr, fontsize=18);
end