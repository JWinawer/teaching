function plotSpins(Spins, M0,stepnum)

% Individual spin vectors
scatter3(Spins(:,1), Spins(:,2), Spins(:,3), 10,  ...
    '.', 'MarkerFaceColor', .8*[1 1 1], 'MarkerFaceAlpha', .3, ...
    'MarkerEdgeColor',.8*[1 1 1], 'MarkerEdgeAlpha', .3);

if stepnum==1, axis([-1 1 -1 1 -1 1]); axis square; end

% Keep current axis properties and plotted data
set(gca, 'NextPlot', 'add'); 
plotAxes();

% Bulk magnetization
M = sum(Spins)/norm(M0);
quiver3(0, 0, 0, M(1), M(2), M(3), 'k-', 'AutoScale', 'off', 'LineWidth', 4); 
quiver3(0, 0, 0, M(1), M(2), 0, 'r-', 'AutoScale', 'off', 'LineWidth', 4); 
quiver3(0, 0, 0, 0, 0, M(3), 'g-', 'AutoScale', 'off', 'LineWidth', 4); 
    
% Keep current axis properties but replace plotted data for next time step
set(gca, 'NextPlot', 'replacechildren');

end