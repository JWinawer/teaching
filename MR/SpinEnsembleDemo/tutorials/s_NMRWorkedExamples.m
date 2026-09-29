% s_NMRWorkedExamples
%
% Worked examples of the spin animations. Run one cell at a time.
% Each cell sets up a parameter struct and calls spinsAnimate. Times are in
% ms, frequencies in Hz and angles in degrees (see spinsDefaultParams).
%
% See also spinsAnimate, spinsDefaultParams

codeDir = fileparts(fileparts(mfilename("fullpath")));
addpath(codeDir);
saveMovie = false;

%% Switching the field on : how a sample becomes magnetized
% The run starts with no field. The spins point in random directions and sit
% still: there is nothing to precess about and no direction to prefer. When
% the field switches on, two things start at the same moment. Every spin
% begins to precess, and the population begins to relax toward the
% Boltzmann distribution, so Mz climbs from 0 toward 1 with time constant T1.
%
% This is T1 recovery, just as after a 90 degree pulse, since both start
% from Mz = 0. The difference is that here there was never any phase
% coherence, so Mxy stays at zero throughout: precession on its own
% produces no signal.
params = spinsDefaultParams();
params.fieldOnTime = 200;     % ms with no field before the switch
params.flipTime    = Inf;     % no RF pulse
params.t1          = 500;
params.t2          = Inf;     % no coherence to lose, so T2 has nothing to do
params.larmor      = 1;       % slow, so the drift toward +z is easy to follow
params.dt          = 10;
params.nSteps      = 200;     % 1.8 s after the switch, about 3.6 T1
params.frameRate   = 25;

spinsAnimate(params, Title="Switching the field on", SaveMovie=saveMovie);

%% Noiseless Larmor precession
params = spinsDefaultParams();
params.flipTime = Inf;   % no flip
params.t1       = Inf;
params.t2       = Inf;

spinsAnimate(params, Title="Noiseless precession", SaveMovie=saveMovie);

%% Noiseless Larmor precession with 90 degree flip
params = spinsDefaultParams();
params.t1 = Inf;
params.t2 = Inf;

spinsAnimate(params, Title="Noiseless precession with flip", SaveMovie=saveMovie);

%% T2 relaxation, laboratory reference frame
params = spinsDefaultParams();

spinsAnimate(params, Title="T2 relaxation in laboratory reference frame", SaveMovie=saveMovie);

%% T2 relaxation, rotating reference frame
params = spinsDefaultParams();
params.larmor = 0;
params.dt     = 2;

spinsAnimate(params, Title="T2 relaxation in rotating reference frame", SaveMovie=saveMovie);

%% T1 and T2 relaxation, rotating reference frame
params = spinsDefaultParams();
params.larmor    = 0;
params.dt        = 1;
params.nSteps    = 500;   % many steps, because T1 recovery is slow
params.flipAngle = 90;
params.flipTime  = 10;

spinsAnimate(params, Title="T1 and T2 relaxation in rotating reference frame", SaveMovie=saveMovie);

%% T1 and T2 relaxation, matched time scales
params = spinsDefaultParams();
params.larmor    = 0;
params.t2        = params.t1;
params.dt        = 10;
params.nSteps    = 150;
params.flipAngle = 90;
params.flipTime  = 100;

spinsAnimate(params, Title="T1 and T2 relaxation with matched time constants", SaveMovie=saveMovie);

%% Slow 90 degree flip in rotating reference frame
params = spinsDefaultParams();
params.dt       = 0.1;
params.nSteps   = 150;
params.flipTime = 1;
params.larmor   = 0;

spinsAnimate(params, Title="Slow 90 degree flip", SaveMovie=saveMovie);

%% Continuous flipping
params = spinsDefaultParams();
params.dt        = 0.1;
params.nSteps    = 150;
params.flipTime  = 1;
params.larmor    = 0;
params.flipAngle = 9000;   % 25 full turns, longer than the run
params.b1Freq    = 250;

spinsAnimate(params, Title="Continuous flipping", SaveMovie=saveMovie);

%% T2* : dephasing from a non-uniform B0
% The field is no longer perfectly uniform, so each spin precesses at a
% slightly different rate and the population fans out in phase. Watch how
% much faster Mxy dies than it did with b0Spread = 0.
params = spinsDefaultParams();
params.larmor   = 0;
params.t1       = Inf;
params.t2       = 200;
params.b0Spread = 16;      % Hz, so t2prime is about 10 ms
params.dt       = 0.2;
params.nSteps   = 250;
params.b1Freq   = 500;     % short pulses, so the flip barely takes any time
params.flipTime = 1;

spinsAnimate(params, Title="T2 star decay from a non-uniform field", SaveMovie=saveMovie);

%% Spin echo : the 180 degree pulse undoes the T2* dephasing
% Same field spread as above, but now a 180 degree pulse at TE/2 flips the
% fan of phases over. The spread from the fixed offsets unwinds itself and
% the signal comes back. The spread from T2 does not come back, because it
% is a random walk, so the echo peaks at exp(-TE/T2), not exp(-TE/T2*).
params = spinsDefaultParams();
params.larmor    = 0;
params.t1        = Inf;
params.t2        = 200;
params.b0Spread  = 16;
params.dt        = 0.1;
params.nSteps    = 600;
params.b1Freq    = 500;
params.flipAngle = [90 180];
params.flipTime  = [1 21];     % the echo lands near 42 ms
params.flipPhase = [0 90];     % 90 about x, 180 about y

spinsAnimate(params, Title="Spin echo", SaveMovie=saveMovie);

%% BOLD : why the fMRI signal changes with oxygenation
% Deoxygenated hemoglobin is paramagnetic, so it distorts the field near a
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
params.t1       = Inf;
params.t2       = 100;     % true T2 of gray matter, roughly
params.dt       = 0.5;
params.nSteps   = 200;
params.b1Freq   = 500;
params.flipTime = 1;
params.nSpins   = 1e5;     % many spins, because the effect is small

TE     = 40;                % echo time, ms
t2star = [40 44];           % ms: rest, then active
labels = ["rest (more deoxygenated)", "active (more oxygenated)"];

figure(Position=[100 100 1000 400]);
tiledlayout(1, 2);

nexttile
hold on
Mxy = cell(1, 2);
for ii = 1:2
    params.b0Spread = spinsB0SpreadForT2star(t2star(ii), params.t2);
    rng(1);                                 % same seed for both conditions
    [M, p] = spinsSimulate(params);
    Mxy{ii} = vecnorm(M(:,1:2), 2, 2);
    plot(p.t, Mxy{ii}, LineWidth=2, DisplayName=sprintf("%s, T2* = %.0f ms", labels(ii), p.t2star));
end
xline(TE, "k--", DisplayName=sprintf("TE = %g ms", TE));
xlabel("Time (ms)");
ylabel("Transverse magnetization, Mxy");
title("Signal decay at two oxygenation levels");
legend(Location="northeast");
set(gca, FontSize=11);
box off

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
signalDifference = Mxy{2} - Mxy{1};
plot(p.t, signalDifference, "k-", LineWidth=2);
hold on
xline(t2star(1), "r--", LineWidth=1.5);
[~, iPeak] = max(signalDifference);
plot(p.t(iPeak), signalDifference(iPeak), "ro", MarkerSize=9, LineWidth=2);
xlabel("Echo time TE (ms)");
ylabel("Signal difference, active - rest");
title("Contrast is largest when TE is near T2*");
legend(["signal difference", "TE = T2*", "peak"], Location="southeast");
set(gca, FontSize=11);
box off
xlim([0 100])

fprintf("\nSignal at TE = %g ms\n", TE);
for ii = 1:2
    fprintf("  %-28s %.4f\n", labels(ii), interp1(p.t, Mxy{ii}, TE));
end
fprintf("  difference                   %.4f\n", interp1(p.t, signalDifference, TE));
fprintf("  percent change               %.1f%%\n", ...
    100*interp1(p.t, signalDifference, TE)/interp1(p.t, Mxy{1}, TE));
fprintf("  contrast peaks at TE         %.0f ms (T2* = %.0f ms)\n", p.t(iPeak), t2star(1));
