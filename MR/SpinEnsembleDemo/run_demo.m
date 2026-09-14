addpath('subroutines');
graphics_toolkit('gnuplot');
set(0, 'defaultfigurevisible', 'off');

diary('run_demo.log');
diary on;

%% 1. Boltzmann elevation density for several k (reproduces tutorial 1, cell 3)
phi = linspace(-pi/2, pi/2, 400);
figure('Position',[0 0 800 500]);
hold on
ks = [0 1 2 3 6];
colors = {'#888888','#1f77b4','#2ca02c','#c98a1f','#b23a1f'};
labelx = [55 60 65 70 73];   % stagger label x-positions so they don't collide
for ii = 1:numel(ks)
    kk = ks(ii);
    B = boltzmannDistribution(kk);
    plot(rad2deg(phi), B.pdf(phi), 'LineWidth', 3, 'Color', colors{ii});
    lx = labelx(ii);
    ly = B.pdf(deg2rad(lx));
    text(lx+2, ly, sprintf('k = %g', kk), 'Color', colors{ii}, ...
        'FontSize', 11, 'FontWeight', 'bold');
end
xlabel('Elevation (degrees)'); ylabel('Probability density');
title('Boltzmann elevation distribution, from boltzmannDistribution.m');
set(gca,'FontSize',12);
xlim([-90 100]);
box off
print('-dpng','-r200','out_boltzmann.png');
close all;

B3 = boltzmannDistribution(3);
fractionUp3 = integral(@(x) B3.pdf(x), 0, pi/2);
fprintf('k=3: fraction of spins with positive elevation = %.4f\n', fractionUp3);
fprintf('k=3: equilibrium Mz per spin (Langevin) = %.4f\n', B3.Mz);

% realistic k at 3T body temperature (reproduces tutorial 1, section 5)
gamma = 2.675e8; hbar = 1.055e-34; kB = 1.381e-23; B0 = 3; Temp = 310;
deltaE = gamma*hbar*B0; thermal = kB*Temp; polarization = deltaE/(2*thermal);
kRealistic = 3*polarization;
fprintf('Realistic polarization at 3T, 310K = %.3e (about 1 in %.0f)\n', polarization, 1/polarization);
fprintf('Realistic k = %.3e ; k used for display = 3 ; exaggeration factor = %.0e\n', kRealistic, 3/kRealistic);

%% 2. T1 recovery after a 90-degree pulse (reproduces s_NMRWorkedExamples T1/T2 cell)
params = spinsDefaultParams();
params.larmor    = 0;      % rotating frame
params.nspins    = 20000;  % enough spins that the curve is clean
params.dt        = 0.002;
params.nsteps    = 1000;   % 2 s, about 2.5 T1, so the curve visibly plateaus
params.t1        = 0.8;
params.t2        = 0.05;
params.flipangle = pi/2;
params.fliptime  = 0.010;
params.k         = 3;

tic;
[M, p] = simulateSpins(params);
toc

figure('Position',[0 0 800 500]);
plot(p.t, M(:,3), 'LineWidth', 3, 'Color', '#1f3a5f'); hold on
text(p.t(end)*0.55, M(round(0.5*numel(p.t)),3)-0.12, 'M_z(t), simulated', ...
    'Color', '#1f3a5f', 'FontSize', 11, 'FontWeight', 'bold');
Beq = boltzmannDistribution(params.k);
plot([p.t(1) p.t(end)], [1 1], '--', 'LineWidth', 2.5, 'Color', '#888888');
text(p.t(end)*0.62, 1.045, 'equilibrium (k=3 scale)', 'Color', '#555555', 'FontSize', 10.5);
plot([params.t1 params.t1], [-0.2 1.05], ':', 'LineWidth', 3.5, 'Color', '#b23a1f');
text(params.t1+0.04, -0.12, 't = T_1', 'Color', '#b23a1f', 'FontSize', 11, 'FontWeight', 'bold');
xlabel('time (s)'); ylabel('M_z / M_0');
title(sprintf('T1 recovery from simulateSpins.m  (nominal T1 = %.2f s)', params.t1));
set(gca,'FontSize',12); box off
print('-dpng','-r200','out_t1_recovery.png');
close all;

% fit a single exponential to the recovery to see how close simulateSpins
% actually lands to the nominal t1 (this is the "measure T1" exercise from
% TEACHING.md section 7)
after = p.t > params.fliptime;
tt = p.t(after) - params.fliptime;
mz = M(after,3);
mzinf = 1;   % simulateSpins normalizes by nspins*B_dist.Mz, so equilibrium Mz is exactly 1
% linearize: log(mzinf - mz) = log(mzinf) - t/T1
valid = (mzinf - mz) > 0.03*mzinf;
pfit = polyfit(tt(valid), log(mzinf - mz(valid)), 1);
T1fit = -1/pfit(1);
fprintf('Fitted T1 from simulated Mz(t) = %.4f s (nominal was %.2f s)\n', T1fit, params.t1);

%% 3. T2 vs T2* vs spin echo (reproduces the last cells of s_NMRWorkedExamples.m)
params2 = spinsDefaultParams();
params2.larmor   = 0;
params2.t1       = inf;
params2.t2       = 0.200;
params2.b0spread = 16;     % Hz -> t2prime about 10 ms
params2.dt       = 2e-4;
params2.nsteps   = 400;
params2.B1freq   = 500;
params2.fliptime = 0.001;
params2.nspins   = 20000;

[M2, p2] = simulateSpins(params2);
Mxy_t2star = vecnorm(M2(:,1:2), 2, 2);

params3 = params2;
params3.nsteps    = 700;
params3.flipangle = [pi/2 pi];
params3.fliptime  = [0.001 0.021];
params3.flipphase = [0 pi/2];
[M3, p3] = simulateSpins(params3);
Mxy_echo = vecnorm(M3(:,1:2), 2, 2);

figure('Position',[0 0 900 500]); hold on
plot(p2.t, Mxy_t2star, 'LineWidth', 3, 'Color', '#b23a1f');
text(0.048, 0.30, sprintf('free decay, T2^* = %.0f ms (T2 = %.0f ms)', 1000*p2.t2star, 1000*p2.t2), ...
    'Color', '#b23a1f', 'FontSize', 10.5, 'FontWeight', 'bold');
plot(p3.t, Mxy_echo, 'LineWidth', 3, 'Color', '#1f3a5f');
text(0.088, 0.22, 'spin echo (90 then 180)', ...
    'Color', '#1f3a5f', 'FontSize', 10.5, 'FontWeight', 'bold');
env = exp(-p3.t/params3.t2);
plot(p3.t, env, '--', 'LineWidth', 2.2, 'Color', '#555555');
text(0.115, exp(-0.115/params3.t2)+0.035, 'exp(-t/T2) envelope', ...
    'Color', '#555555', 'FontSize', 10.5);
xlabel('time (s)'); ylabel('M_{xy}');
title('T2^* decay vs. spin echo, from simulateSpins.m');
set(gca,'FontSize',12); box off
print('-dpng','-r200','out_t2star_echo.png');
close all;

[~, iEcho] = max(Mxy_echo(round(0.03/params3.dt):end));
iEcho = iEcho + round(0.03/params3.dt) - 1;
fprintf('Spin echo peak at t = %.4f s, Mxy = %.4f (exp(-TE/T2) predicts %.4f)\n', ...
    p3.t(iEcho), Mxy_echo(iEcho), exp(-p3.t(iEcho)/params3.t2));

diary off;
disp('DONE');
