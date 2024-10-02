function plotBulk(t, M)

idx = size(M,1);
if idx >= 2, idx = [-1 0] + idx; end
Mz  = M(idx,3);
Mxy = vecnorm(M(idx, 1:2), 2, 2);
plot(t(idx), Mz, 'g.-', t(idx), Mxy,  'r.-');

hold on; 
if size(M,1) == 1
    axis([0 max(t) -1 1.1]); 
    axis square
    xlabel('Time (s)')
    ylabel('Magnetization')

    legend({'Mz', 'Mxy'},'AutoUpdate','off', 'Location','southwest');
end

end