function tests = testSpins
% Tests for the spin demo. Run with runtests("tests") from the demo folder.
%
% The accuracy tests measure time constants from the simulated
% magnetization and compare them with the nominal values, which is the
% check that caught a 5% miscalibration of T2 in September 2026 (see
% docs/TEACHING.md, section 7). The simulation is random, so each test
% fixes the random seed and allows a small tolerance.

tests = functiontests(localfunctions);
end

function setupOnce(testCase)
demoFolder = fileparts(fileparts(mfilename("fullpath")));
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(demoFolder));
spinsCheckPaths();
end

function setup(~)
rng(1);
end

function params = decayParams()
% Rotating frame, no T1, a short 90 degree pulse at 1 ms
params = spinsDefaultParams();
params.larmor   = 0;
params.t1       = Inf;
params.nSpins   = 20000;
params.dt       = 0.2;     % ms
params.b1Freq   = 500;     % Hz, so the pulse lasts 0.5 ms
params.flipTime = 1;       % ms
end

function timeConstant = fitDecay(t, signal, startTime)
% Fit signal = exp(-(t - startTime)/timeConstant) on a log scale, down to
% 5% of the starting value
isFitted = (t > startTime) & (signal > 0.05);
coefficients = polyfit(t(isFitted), log(signal(isFitted)), 1);
timeConstant = -1/coefficients(1);
end

function testT2(testCase)
params = decayParams();
params.t2     = 50;
params.nSteps = 800;
[M, p] = spinsSimulate(params);
mxy = vecnorm(M(:,1:2), 2, 2)';
verifyEqual(testCase, fitDecay(p.t, mxy, 2), params.t2, RelTol=0.03);
end

function testT2star(testCase)
params = decayParams();
params.t2       = 200;
params.b0Spread = 16;
params.nSteps   = 250;
[M, p] = spinsSimulate(params);
mxy = vecnorm(M(:,1:2), 2, 2)';
verifyEqual(testCase, fitDecay(p.t, mxy, 2), p.t2star, RelTol=0.05);
end

function testT1(testCase)
% The calibration in spinsRelaxT1 is for this case: a 90 degree pulse
% applied to the equilibrium distribution. It lands within about 2%.
params = spinsDefaultParams();
params.larmor   = 0;
params.nSpins   = 20000;
params.dt       = 2;
params.nSteps   = 1000;
params.t1       = 800;
params.flipTime = 10;
[M, p] = spinsSimulate(params);
recovery = 1 - M(:,3)';
verifyEqual(testCase, fitDecay(p.t, recovery, params.flipTime), params.t1, RelTol=0.03);
end

function testSpinEchoPeak(testCase)
% The echo recovers the dephasing from the field spread, but not T2, so it
% peaks at exp(-TE/T2)
params = decayParams();
params.t2        = 200;
params.b0Spread  = 16;
params.nSteps    = 350;
params.flipAngle = [90 180];
params.flipTime  = [1 21];
params.flipPhase = [0 90];
[M, p] = spinsSimulate(params);
mxy = vecnorm(M(:,1:2), 2, 2)';
isLate = p.t > 30;
[peak, iPeak] = max(mxy(isLate));
tLate = p.t(isLate);
verifyEqual(testCase, tLate(iPeak), 42, AbsTol=1.5);
verifyEqual(testCase, peak, exp(-tLate(iPeak)/params.t2), RelTol=0.05);
end

function testNinetyDegreeFlip(testCase)
params = decayParams();
params.t2     = Inf;
params.nSteps = 20;
M = spinsSimulate(params);
verifyEqual(testCase, M(end,3), 0, AbsTol=0.05);
verifyEqual(testCase, norm(M(end,1:2)), 1, AbsTol=0.05);
end

function testNoFieldNoMagnetization(testCase)
params = spinsDefaultParams();
params.k        = 0;
params.larmor   = 0;
params.flipTime = Inf;
params.nSteps   = 5;
M = spinsSimulate(params);
verifyLessThan(testCase, max(vecnorm(M, 2, 2)), 0.1);
end

function testBoltzmannMz(testCase)
% The equilibrium Mz is the mean of sin(elevation) under the density
k = 3;
B = spinsBoltzmannDistribution(k);
meanSin = integral(@(x) sin(x).*B.pdf(x), -pi/2, pi/2);
verifyEqual(testCase, B.Mz, meanSin, AbsTol=1e-6);
verifyEqual(testCase, integral(B.pdf, -pi/2, pi/2), 1, AbsTol=1e-6);
end

function testB0SpreadForT2star(testCase)
params = spinsDefaultParams();
params.t2 = 100;
params.b0Spread = spinsB0SpreadForT2star(40, params.t2);
params = spinsDerivedParams(params);
verifyEqual(testCase, params.t2star, 40, RelTol=1e-12);
verifyError(testCase, @() spinsB0SpreadForT2star(100, 50), "spins:impossibleT2star");
end

function testUnknownParameterIsAnError(testCase)
params = spinsDefaultParams();
params.flipangle = 90;   % old name for flipAngle
verifyError(testCase, @() spinsSimulate(params), "spins:unknownParameter");
try
    spinsSimulate(params);
catch err
    verifySubstring(testCase, err.message, "flipAngle");
end
end

function testMissingParametersTakeDefaults(testCase)
params.nSteps = 5;
M = spinsSimulate(params);
verifySize(testCase, M, [5 3]);
end

function testOldUnitsWarn(testCase)
params = spinsDefaultParams();
params.t2 = 0.05;   % looks like seconds
verifyWarning(testCase, @() spinsDerivedParams(params), "spins:unitsLookLikeSeconds");
params = spinsDefaultParams();
params.flipAngle = pi/2;   % looks like radians
verifyWarning(testCase, @() spinsDerivedParams(params), "spins:anglesLookLikeRadians");
end

function testPulseTooShortWarns(testCase)
params = spinsDefaultParams();
params.b1Freq   = 500;    % a 0.5 ms pulse, shorter than the 1 ms time step...
params.flipTime = 25.2;   % ...and starting between steps, so no step falls in it
verifyWarning(testCase, @() spinsDerivedParams(params), "spins:pulseTooShort");
end

function testAnimation(testCase)
f = figure(Visible="off");
testCase.addTeardown(@() close(f));
params = spinsDefaultParams();
params.nSteps    = 3;
params.frameRate = 1000;
[M, p] = spinsAnimate(params, Figure=f, Title="test");
verifySize(testCase, M, [3 3]);
verifyEqual(testCase, p.t, [1 2 3]);
end
