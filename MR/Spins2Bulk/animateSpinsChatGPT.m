function animateSpinsChatGPT(P, figureHandle, titleStr)

% Set up the figure if it's not provided
if ~exist("figureHandle", 'var'), figureHandle = figure(); end
if ~exist('titleStr', 'var'), titleStr = []; end
clf(figureHandle); layout = tiledlayout(2,2);
title(layout, titleStr);

% Time and pulse parameters
timeSteps         = (1:P.nsteps) * P.dt; % seconds
P.larmorPrecessionStep = P.larmor * P.dt * 2 * pi; % radians
P.t2DecayStep     = sqrt(1.9/P.t2 * P.dt); % random walk causing T2 decay
flipDuration      = P.flipangle / (2*pi) / P.B1freq;
P.isRFPulseActive = timeSteps >= P.fliptime & timeSteps < P.fliptime + flipDuration;

% Initialize spins at thermal equilibrium
[spins, boltzmannDist, M0] = initializeSpins(P);

% Main loop for spin dynamics
for stepIdx = 1:P.nsteps
    P.currentStep = stepIdx;

    % Update spin vectors for Larmor precession, B1 flip, T2, and T1 relaxation
    spins = rotateAroundB0(spins, P);
    spins = applyB1Pulse(spins, P);
    spins = applyT2Relaxation(spins, P);
    spins = applyT1Relaxation(spins, P, boltzmannDist);

    % Bulk magnetization vector
    bulkMagnetization(stepIdx,:) = sum(spins) / norm(M0);

    % Plot instantaneous spins and histograms
    nexttile(1);
    plotSpins(spins, M0);

    nexttile(2);
    plotMagnetization(timeSteps, stepIdx, bulkMagnetization);

    nexttile(3);
    plotAngleHistogram(spins, 'Azimuth', 'red', [-180 180], stepIdx);

    nexttile(4);
    plotAngleHistogram(spins, 'Elevation', 'green', [-90 90], stepIdx);
    
    drawnow();
end

end

% --------------------------------------------------------------
% ******************** SUPPORTING FUNCTIONS ********************
% --------------------------------------------------------------

function boltzmannDist = boltzmannDistribution(k)

elevation = linspace(-pi/2, pi/2, 10000);
dx = elevation(2) - elevation(1);

% Boltzmann probability distribution
energy = @(theta) -cos(theta - pi/2);
probability = @(theta) exp(-k * energy(theta)) .* abs(cos(theta));
pdf = @(theta) probability(theta) / sum(probability(theta)) / dx;

% Cumulative distribution function (CDF)
pdfValues = pdf(elevation);
cdfValues = cumsum(pdfValues);
cdfValues = cdfValues / cdfValues(end);

% Ensure CDF starts at 0 and ends at 1
cdfValues(1) = 0;
cdfValues(end) = 1;

boltzmannDist = makedist('PiecewiseLinear', 'x', elevation, 'Fx', cdfValues);

end

function [spins, boltzmannDist, M0] = initializeSpins(params)

boltzmannDist = boltzmannDistribution(params.k);

% Sample spin elevations and random azimuths
elevation = random(boltzmannDist, 1, params.nspins);
azimuth = rand(size(elevation)) * 2 * pi;

% Convert to Cartesian coordinates
r = ones(size(azimuth));
[x, y, z] = sph2cart(azimuth, elevation, r);
spins = [x; y; z]';

% Initial bulk magnetization
M0 = sum(spins);

end

function spins = applyT1Relaxation(spins, params, boltzmannDist)

[azimuth, elevation, r] = cart2sph(spins(:,1), spins(:,2), spins(:,3));
stepSize = sqrt(params.dt) / params.t1 / sqrt(params.k) / sqrt(2);

% Probabilities for spin reorientation
probUp = boltzmannDist.pdf(elevation + stepSize);
probDown = boltzmannDist.pdf(elevation - stepSize);
probUp = probUp ./ (probUp + probDown);

% Spin reorientation
spinFlip = probUp > rand(size(elevation));
elevation = elevation + stepSize * (2 * spinFlip - 1);

% Convert back to Cartesian coordinates
[x, y, z] = sph2cart(azimuth, elevation, r);
spins = [x, y, z];

end

function spins = rotateAroundB0(spins, params)

% Apply Larmor precession to spin vectors
[azimuth, elevation, r] = cart2sph(spins(:,1), spins(:,2), spins(:,3));
azimuth = azimuth + params.larmorPrecessionStep;

% Convert back to Cartesian coordinates
[x, y, z] = sph2cart(azimuth, elevation, r);
spins = [x, y, z];

end

function spins = applyT2Relaxation(spins, params)

% Apply random walk for T2 relaxation
[azimuth, elevation, r] = cart2sph(spins(:,1), spins(:,2), spins(:,3));
azimuth = azimuth + randn(size(azimuth)) * params.t2DecayStep;

% Convert back to Cartesian coordinates
[x, y, z] = sph2cart(azimuth, elevation, r);
spins = [x, y, z];

end

function spins = applyB1Pulse(spins, params)

if params.isRFPulseActive(params.currentStep)
    % Apply B1 pulse as a rotation about the axis
    rotationAngle = params.B1freq * 2 * pi * params.dt;
    rotationAxisAngle = params.currentStep * params.larmor * 2 * pi * params.dt;
    
    rotationMatrix = axang2rotm([cos(rotationAxisAngle) sin(rotationAxisAngle) 0 rotationAngle]);
    spins = spins * rotationMatrix;
end

end

function plotSpins(spins, M0)

% Plot individual spin vectors
scatter3(spins(:,1), spins(:,2), spins(:,3), 10, '.', 'MarkerEdgeColor', [0.8 0.8 0.8], 'MarkerEdgeAlpha', 0.3);
axis([-1 1 -1 1 -1 1]); axis square;
hold on;

% Plot bulk magnetization vector
M = sum(spins) / norm(M0);
quiver3(0, 0, 0, M(1), M(2), M(3), 'k-', 'AutoScale', 'off', 'LineWidth', 4); 
quiver3(0, 0, 0, M(1), M(2), 0, 'r-', 'AutoScale', 'off', 'LineWidth', 4); 
quiver3(0, 0, 0, 0, 0, M(3), 'g-', 'AutoScale', 'off', 'LineWidth', 4);

hold off;

end

function plotMagnetization(timeSteps, stepIdx, magnetization)

t = timeSteps(1:stepIdx)';
plot(t, magnetization(:,3), 'g.-', t, vecnorm(magnetization(:, 1:2), 2, 2), 'r.-');
if stepIdx == 1
    axis([0 max(timeSteps) -1 1.1]); axis square;
    xlabel('Time (s)');
    ylabel('Magnetization');
    legend({'Mz', 'Mxy'}, 'Location', 'southwest');
    set(gca, "NextPlot", "replacechildren");
end

end

function plotAngleHistogram(spins, angleType, color, angleRange, stepIdx)

[azimuth, elevation] = cart2sph(spins(:,1), spins(:,2), spins(:,3));
switch lower(angleType)
    case 'azimuth', angleData = rad2deg(azimuth); 
    case 'elevation', angleData = rad2deg(elevation); 
end

histogram(angleData, linspace(angleRange(1), angleRange(2), 100), 'FaceColor', color);

if stepIdx == 1
    title(angleType);
    axis square;    
    set(gca, 'NextPlot', 'replacechildren', 'YLim', 2*get(gca, 'YLim'));
end

end
