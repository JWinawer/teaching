function plotSpins(Spins, M0,stepnum)

% Individual spin vectors
scatter3(Spins(:,1), Spins(:,2), Spins(:,3), 20,  ...
    '.', 'MarkerFaceColor', .8*[1 1 1], 'MarkerFaceAlpha', .3, ...
    'MarkerEdgeColor',.8*[1 1 1], 'MarkerEdgeAlpha', .3);

if stepnum==1, axis([-1 1 -1 1 -1 1]); axis square; end

% Keep current axis properties and plotted data
set(gca, 'NextPlot', 'add'); 
plotAxes();

% Bulk magnetization
M = sum(Spins)/norm(M0);

plot3([0  M(1)], [0 M(2)], [0 M(3)], 'k-', ... total M0
   [0, M(1)], [0, M(2)], [0, 0],'r-', ... transverse component
   [0,0], [0, 0], [0, M(3)], 'g-', ... longitudinal component
   'LineWidth', 4); 

% Keep current axis properties but replace plotted data for next time step
set(gca, 'NextPlot', 'replacechildren', 'View', [-10 30]);

end