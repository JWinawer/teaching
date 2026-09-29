% s_makeRelaxationFigures
%
% Make Figures 6-8 of docs/nmr_relaxation_summary.md and print the numbers
% quoted in their captions. Each section also stands on its own as a short
% demonstration of the simulation without animation:
%
%   1. The Boltzmann elevation distribution for several values of k
%   2. T1 recovery after a 90 degree pulse, with a fitted T1
%   3. T2* free decay versus a spin echo
%
% The figures are written to docs/figures, replacing the existing ones. The
% random seed is fixed, so a rerun gives the same figures and numbers.
%
% See also spinsSimulate, spinsBoltzmannDistribution, s_NMRWorkedExamples

scriptDir = fileparts(mfilename("fullpath"));
codeDir = fileparts(scriptDir);
addpath(codeDir);

figureDir = fullfile(codeDir, "docs", "figures");
if ~isfolder(figureDir)
    mkdir(figureDir);
end

figureResolution = 200;   % dots per inch
fontSize = 12;
labelFontSize = 11;
rng(1);

%% 1. Boltzmann elevation density for several k (as in tutorial 1, section 3)
elevation = linspace(-pi/2, pi/2, 400);
kValues = [0 1 2 3 6];
kColors = ["#888888" "#1f77b4" "#2ca02c" "#c98a1f" "#b23a1f"];
% Each label sits just left of its curve's rising side. The steeper curves get
% higher labels, so that neighboring labels do not run into each other.
labelDensity = [0.25 0.25 0.25 0.9 1.3];
labelGap = 3;   % degrees between the end of a label and its curve

fig = figure(Position=[100 100 800 500]);
hold on
for ii = 1:numel(kValues)
    B = spinsBoltzmannDistribution(kValues(ii));
    density = B.pdf(elevation);
    plot(rad2deg(elevation), density, LineWidth=3, Color=kColors(ii));
    iCross = find(density >= labelDensity(ii), 1);
    text(rad2deg(elevation(iCross)) - labelGap, labelDensity(ii), sprintf("k = %g", kValues(ii)), ...
        Color=kColors(ii), FontSize=labelFontSize, FontWeight="bold", ...
        HorizontalAlignment="right");
end
xlabel("Elevation (degrees)")
ylabel("Probability density")
title("Boltzmann elevation distribution, from spinsBoltzmannDistribution.m")
set(gca, FontSize=fontSize)
xlim([-90 100])
box off
exportgraphics(fig, fullfile(figureDir, "relaxation_fig6_boltzmann_distribution.png"), ...
    Resolution=figureResolution);

kDisplay = 3;
B3 = spinsBoltzmannDistribution(kDisplay);
fractionUp = integral(@(x) B3.pdf(x), 0, pi/2);
fprintf("k = %g: fraction of spins with positive elevation = %.4f\n", kDisplay, fractionUp);
fprintf("k = %g: equilibrium Mz per spin (Langevin) = %.4f\n", kDisplay, B3.Mz);

% Realistic bias at 3 T and body temperature (as in tutorial 1, section 5)
gyromagneticRatio = 2.675e8;   % rad/s/T, hydrogen
hbar = 1.055e-34;              % J s
boltzmannConstant = 1.381e-23; % J/K
B0 = 3;                        % T
bodyTemperature = 310;         % K
deltaE = gyromagneticRatio*hbar*B0;
thermalEnergy = boltzmannConstant*bodyTemperature;
polarization = deltaE/(2*thermalEnergy);
kRealistic = 3*polarization;
fprintf("Realistic polarization at 3 T, 310 K = %.3e (about 1 in %.0f)\n", ...
    polarization, 1/polarization);
fprintf("Realistic k = %.3e; k used for display = %g; exaggeration factor = %.0e\n", ...
    kRealistic, kDisplay, kDisplay/kRealistic);

%% 2. T1 recovery after a 90 degree pulse (as in s_NMRWorkedExamples.m)
params = spinsDefaultParams();
params.larmor    = 0;      % rotating frame
params.nSpins    = 20000;  % enough spins that the curve is clean
params.dt        = 2;      % ms
params.nSteps    = 1000;   % 2 s, about 2.5 T1, so the curve visibly plateaus
params.t1        = 800;    % ms
params.t2        = 50;     % ms
params.flipAngle = 90;     % degrees
params.flipTime  = 10;     % ms
params.k         = kDisplay;

[M, p] = spinsSimulate(params);

mzColor = "#1f3a5f";
equilibriumColor = "#888888";
t1Color = "#b23a1f";

fig = figure(Position=[100 100 800 500]);
hold on
plot(p.t, M(:,3), LineWidth=3, Color=mzColor);
text(p.t(end)*0.55, M(round(0.5*numel(p.t)),3) - 0.12, "M_z(t), simulated", ...
    Color=mzColor, FontSize=labelFontSize, FontWeight="bold");
plot([p.t(1) p.t(end)], [1 1], "--", LineWidth=2.5, Color=equilibriumColor);
text(p.t(end)*0.62, 1.045, "equilibrium (k = 3 scale)", Color="#555555", ...
    FontSize=labelFontSize - 0.5);
plot([params.t1 params.t1], [-0.2 1.05], ":", LineWidth=3.5, Color=t1Color);
text(params.t1 + 40, -0.12, "t = T_1", Color=t1Color, ...
    FontSize=labelFontSize, FontWeight="bold");
xlabel("time (ms)")
ylabel("M_z / M_0")
title(sprintf("T1 recovery from spinsSimulate.m  (nominal T1 = %.0f ms)", params.t1))
set(gca, FontSize=fontSize)
box off
exportgraphics(fig, fullfile(figureDir, "relaxation_fig7_t1_recovery_simulation.png"), ...
    Resolution=figureResolution);

% Fit a single exponential to the recovery to see how close spinsSimulate
% lands to the nominal t1. This is the "measure T1" exercise from
% docs/TEACHING.md, section 7.
isAfterPulse = p.t > params.flipTime;
tAfter = p.t(isAfterPulse) - params.flipTime;
mzAfter = M(isAfterPulse, 3);
mzEquilibrium = 1;   % spinsSimulate normalizes so that equilibrium Mz is exactly 1
% Linearize: log(mzEquilibrium - mz) = log(mzEquilibrium) - t/T1
fitThreshold = 0.03;
isFitted = (mzEquilibrium - mzAfter) > fitThreshold*mzEquilibrium;
fitCoefficients = polyfit(tAfter(isFitted), log(mzEquilibrium - mzAfter(isFitted)), 1);
t1Fitted = -1/fitCoefficients(1);
fprintf("Fitted T1 from simulated Mz(t) = %.1f ms (nominal was %.0f ms)\n", t1Fitted, params.t1);

%% 3. T2* free decay versus spin echo (as in the last cells of s_NMRWorkedExamples.m)
params2 = spinsDefaultParams();
params2.larmor   = 0;
params2.t1       = Inf;
params2.t2       = 200;    % ms
params2.b0Spread = 16;     % Hz, so t2prime is about 10 ms
params2.dt       = 0.2;    % ms
params2.nSteps   = 400;
params2.b1Freq   = 500;    % Hz
params2.flipTime = 1;      % ms
params2.nSpins   = 20000;

[M2, p2] = spinsSimulate(params2);
mxyFreeDecay = vecnorm(M2(:,1:2), 2, 2);

params3 = params2;
params3.nSteps    = 700;
params3.flipAngle = [90 180];   % degrees
params3.flipTime  = [1 21];     % ms; the echo lands near 42 ms
params3.flipPhase = [0 90];     % 90 about x, 180 about y
[M3, p3] = spinsSimulate(params3);
mxyEcho = vecnorm(M3(:,1:2), 2, 2);

freeDecayColor = "#b23a1f";
echoColor = "#1f3a5f";
envelopeColor = "#555555";

fig = figure(Position=[100 100 900 500]);
hold on
plot(p2.t, mxyFreeDecay, LineWidth=3, Color=freeDecayColor);
% The free decay label sits just past the end of the red curve, above the
% tail of the echo; the echo label sits just right of the echo's falling side
text(p2.t(end) + 3, 0.08, sprintf("free decay, T2^* = %.0f ms (T2 = %.0f ms)", ...
    p2.t2star, p2.t2), Color=freeDecayColor, ...
    FontSize=labelFontSize - 0.5, FontWeight="bold");
plot(p3.t, mxyEcho, LineWidth=3, Color=echoColor);
text(58, 0.42, "spin echo (90 then 180)", Color=echoColor, ...
    FontSize=labelFontSize - 0.5, FontWeight="bold");
envelope = exp(-p3.t/params3.t2);
plot(p3.t, envelope, "--", LineWidth=2.2, Color=envelopeColor);
envelopeLabelTime = 115;
text(envelopeLabelTime, exp(-envelopeLabelTime/params3.t2) + 0.035, "exp(-t/T2) envelope", ...
    Color=envelopeColor, FontSize=labelFontSize - 0.5);
xlabel("time (ms)")
ylabel("M_{xy}")
title("T2^* decay vs. spin echo, from spinsSimulate.m")
set(gca, FontSize=fontSize)
box off
exportgraphics(fig, fullfile(figureDir, "relaxation_fig8_t2star_spin_echo.png"), ...
    Resolution=figureResolution);

% Find the echo peak, ignoring the initial free decay before 30 ms
echoSearchStart = round(30/params3.dt);
[~, iEcho] = max(mxyEcho(echoSearchStart:end));
iEcho = iEcho + echoSearchStart - 1;
fprintf("Free decay T2* = %.1f ms\n", p2.t2star);
fprintf("Spin echo peak at t = %.1f ms, Mxy = %.4f (exp(-TE/T2) predicts %.4f)\n", ...
    p3.t(iEcho), mxyEcho(iEcho), exp(-p3.t(iEcho)/params3.t2));
