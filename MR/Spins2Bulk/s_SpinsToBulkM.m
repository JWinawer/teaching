% s_SpinsToBulkM
%
% Worked examples of the spin animations. Run one cell at a time.
% Each cell sets up a parameter struct and calls animateSpins.
%
% See also ANIMATESPINS, SPINSDEFAULTPARAMS

addpath(fullfile(fileparts(mfilename('fullpath')), 'subroutines'));
saveMovieFlag = false;

%% Noiseless Larmor precession
fH = figure;
params = spinsDefaultParams();
params.fliptime = inf;   % no flip
params.t1       = inf;
params.t2       = inf;

titlestr = 'Noiseless precession';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% Noiseless Larmor precession with 90 degree flip
fH = figure;
params = spinsDefaultParams();
params.t1 = inf;
params.t2 = inf;

titlestr = 'Noiseless precession with flip';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% T2 relaxation, laboratory reference frame
fH = figure;
params = spinsDefaultParams();

titlestr = 'T2 relaxation in laboratory reference frame';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% T2 relaxation, rotating reference frame
fH = figure;
params = spinsDefaultParams();
params.larmor = 0;
params.dt     = 0.002;

titlestr = 'T2 relaxation in rotating reference frame';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% T1 and T2 relaxation, rotating reference frame
fH = figure;
params = spinsDefaultParams();
params.larmor    = 0;
params.dt        = 0.001;
params.nsteps    = 500;   % many steps, because T1 recovery is slow
params.flipangle = pi/2;
params.fliptime  = 0.0100;

titlestr = 'T1 and T2 relaxation in rotating reference frame';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% T1 and T2 relaxation, matched time scales
fH = figure;
params = spinsDefaultParams();
params.larmor    = 0;
params.t2        = params.t1;
params.dt        = 0.01;
params.nsteps    = 150;
params.flipangle = pi/2;
params.fliptime  = 0.100;

titlestr = 'T1 and T2 relaxation with matched time constants';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% Slow 90 degree flip in rotating reference frame
fH = figure;
params = spinsDefaultParams();
params.dt       = 0.0001;
params.nsteps   = 150;
params.fliptime = 0.001;
params.larmor   = 0;

titlestr = 'Slow 90 degree flip';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% Continuous flipping
fH = figure;
params = spinsDefaultParams();
params.dt        = 0.0001;
params.nsteps    = 150;
params.fliptime  = 0.001;
params.larmor    = 0;
params.flipangle = 50*pi;
params.B1freq    = 250;

titlestr = 'Continuous flipping';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% T2* : dephasing from a non-uniform B0
% The field is no longer perfectly uniform, so each spin precesses at a
% slightly different rate and the population fans out in phase. Watch how
% much faster Mxy dies than it did with b0spread = 0.
fH = figure;
params = spinsDefaultParams();
params.larmor    = 0;
params.t1        = inf;
params.t2        = 0.200;
params.b0spread  = 16;      % Hz, so t2prime is about 10 ms
params.dt        = 2e-4;
params.nsteps    = 250;
params.B1freq    = 500;     % short pulses, so the flip barely takes any time
params.fliptime  = 0.001;

titlestr = 'T2 star decay from a non-uniform field';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% Spin echo : the 180 degree pulse undoes the T2* dephasing
% Same field spread as above, but now a 180 degree pulse at TE/2 flips the
% fan of phases over. The spread from the fixed offsets unwinds itself and
% the signal comes back. The spread from T2 does not come back, because it
% is a random walk, so the echo peaks at exp(-TE/T2), not exp(-TE/T2*).
fH = figure;
params = spinsDefaultParams();
params.larmor    = 0;
params.t1        = inf;
params.t2        = 0.200;
params.b0spread  = 16;
params.dt        = 1e-4;
params.nsteps    = 600;
params.B1freq    = 500;
params.flipangle = [pi/2 pi];        % 90 then 180
params.fliptime  = [0.001 0.021];    % the echo lands near t = 0.042 s
params.flipphase = [0 pi/2];         % 90 about x, 180 about y

titlestr = 'Spin echo';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% BOLD : why the fMRI signal changes with oxygenation
% Deoxygenated haemoglobin is paramagnetic, so it distorts the field near a
% vessel and widens the spread of B0 offsets. That shortens T2*, so at a
% fixed echo time there is less signal left. When a region activates, blood
% flow rises, the blood becomes more oxygenated, the field gets smoother,
% T2* lengthens, and more signal survives to TE. That difference is BOLD.
%
% Note that the oxygenation change here is exaggerated. A real BOLD response
% at 3T changes T2* by roughly 1%, giving a signal change of a few percent
% at most. We use 10% so that it is visible above the sampling noise of a
% simulation with a finite number of spins.
%
% No animation, just the decay curves and the signal difference at TE.
%
% Both conditions are run from the same random seed. The spins then start in
% the same places and their field offsets differ only by the scale factor we
% are actually interested in, so the sampling noise largely cancels when we
% subtract. That makes the small difference between the two curves visible
% without needing a huge number of spins.
params = spinsDefaultParams();
params.larmor   = 0;
params.t1       = inf;
params.t2       = 0.100;    % true T2 of grey matter, roughly
params.dt       = 5e-4;
params.nsteps   = 200;
params.B1freq   = 500;
params.fliptime = 0.001;
params.nspins   = 1e5;      % many spins, because the effect is small

TE       = 0.040;                       % echo time, seconds
t2star   = [0.040 0.044];               % rest, then active
labels   = {'rest (more deoxygenated)', 'active (more oxygenated)'};

figure('Position',[100 100 1000 400]);
tiledlayout(1,2);

nexttile; hold on
Mxy = cell(1,2);
for ii = 1:2
    params.b0spread = b0spreadForT2star(t2star(ii), params.t2);
    rng(1);                                 % same seed for both conditions
    [M, p] = simulateSpins(params);
    Mxy{ii} = vecnorm(M(:,1:2), 2, 2);
    plot(p.t, Mxy{ii}, 'LineWidth', 2, 'DisplayName', ...
        sprintf('%s, T2* = %.0f ms', labels{ii}, 1000*p.t2star));
end
xline(TE, 'k--', 'DisplayName', sprintf('TE = %g ms', 1000*TE));
xlabel('Time (s)'); ylabel('Transverse magnetization, Mxy');
title('Signal decay at two oxygenation levels');
legend('Location','northeast'); set(gca,'FontSize',11); box off

% How much signal difference you actually capture depends on when you read
% it out. Wait too little and the two curves have not separated; wait too
% long and there is no signal left in either. The difference is largest near
% TE = T2*, which is why fMRI sequences are set up that way.
%
% Note that the *percent* change does not peak: it keeps growing with TE,
% because the signal you are taking a percentage of is shrinking. What peaks
% is the absolute difference, and that is what matters, because the noise in
% an fMRI measurement is roughly constant rather than proportional to signal.
nexttile
dS = Mxy{2} - Mxy{1};
plot(p.t, dS, 'k-', 'LineWidth', 2); hold on
xline(t2star(1), 'r--', 'LineWidth', 1.5);
[~, ipk] = max(dS);
plot(p.t(ipk), dS(ipk), 'ro', 'MarkerSize', 9, 'LineWidth', 2);
xlabel('Echo time TE (s)'); ylabel('Signal difference, active - rest');
title('Contrast is largest when TE is near T2*');
legend({'signal difference', 'TE = T2*', 'peak'}, 'Location','southeast');
set(gca,'FontSize',11); box off; xlim([0 0.1])

fprintf('\nSignal at TE = %g ms\n', 1000*TE);
for ii = 1:2
    fprintf('  %-28s %.4f\n', labels{ii}, interp1(p.t, Mxy{ii}, TE));
end
fprintf('  difference                   %.4f\n', interp1(p.t, dS, TE));
fprintf('  percent change               %.1f%%\n', ...
    100*interp1(p.t, dS, TE)/interp1(p.t, Mxy{1}, TE));
fprintf('  contrast peaks at TE         %.0f ms (T2* = %.0f ms)\n', ...
    1000*p.t(ipk), 1000*t2star(1));
