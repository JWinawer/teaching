function tests = testKspace
% Tests for the k-space demo. Run with runtests("tests") from the demo folder.
%
% The accuracy tests compare the simulation with results that can be worked
% out by hand: the image should match the object when there is no field
% error, a uniform field offset should shift an EPI image by a predictable
% number of pixels, the center of k-space should be sampled at TE, and T2*
% should shrink the signal by exp(-TE/T2*).

tests = functiontests(localfunctions);
end

function setupOnce(testCase)
demoFolder = fileparts(fileparts(mfilename("fullpath")));
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(demoFolder));
kspaceCheckPaths();

params = kspaceDefaultParams();
params.fieldErrorType = "none";
testCase.TestData.params = params;
testCase.TestData.epi = kspaceSimulate(params);
end

function truth = objectAtReconResolution(result)
truth = imresize(result.object.image, result.sim.nPixels*[1 1]);
end

function testEpiMatchesObject(testCase)
result = testCase.TestData.epi;
truth  = objectAtReconResolution(result);
verifyGreaterThan(testCase, corr(result.recon(:), truth(:)), 0.98);
end

function testSpiralMatchesObject(testCase)
params = testCase.TestData.params;
params.sequenceType = "spiral";
result = kspaceSimulate(params);
truth  = objectAtReconResolution(result);
verifyGreaterThan(testCase, corr(result.recon(:), truth(:)), 0.95);

% Spiral and EPI images should be on the same scale
epi = testCase.TestData.epi;
verifyEqual(testCase, mean(result.recon(:)), mean(epi.recon(:)), RelTol=0.3);
end

function testEpiShiftFromFieldOffset(testCase)
% A uniform offset of df Hz shifts an EPI image along the phase encode
% direction by df/(bandwidth per pixel) = df*nPixels^2*dt pixels, and not at
% all along the readout.
params = testCase.TestData.params;
params.fieldErrorType = "dc offset";
params.fieldErrorPpm  = 0.5;
shifted = kspaceSimulate(params);
reference = testCase.TestData.epi;

sim = shifted.sim;
n   = sim.nPixels;
offsetHz = sim.fieldErrorFraction*sim.B0*sim.gamma/(2*pi);
predictedShift = offsetHz*n^2*sim.dt;

crossCorrelation = real(ifft2(fft2(shifted.recon).*conj(fft2(reference.recon))));
[~, peak] = max(crossCorrelation(:));
[rowShift, colShift] = ind2sub(size(crossCorrelation), peak);
rowShift = mod(rowShift - 1 + n/2, n) - n/2;
colShift = mod(colShift - 1 + n/2, n) - n/2;

verifyEqual(testCase, rowShift, 0);
verifyEqual(testCase, colShift, round(predictedShift));
end

function testCenterSampledAtEchoTime(testCase)
for sequence = ["epi", "spiral"]
    params = testCase.TestData.params;
    params.sequenceType = sequence;
    result = kspaceSimulate(params);
    g = result.gradients;
    tCenter = (g.delayDwells + sum(g.nDwells(1:g.centerIndex)))*result.sim.dt;
    verifyEqual(testCase, tCenter, params.echoTime/1000, "AbsTol", 1e-9, ...
        "Center of k-space not at TE for " + sequence);
end
end

function testShortEchoTimeIsAnError(testCase)
params = testCase.TestData.params;
params.echoTime = 30;   % below the 33 ms minimum for the default EPI
verifyError(testCase, @() kspaceSimulate(params), "kspace:echoTimeTooShort");
end

function testT2starDecay(testCase)
params = testCase.TestData.params;
params.t2star = 50;
decayed = kspaceSimulate(params);
c = decayed.gradients.centerIndex;
ratio = abs(decayed.kspace.samples.signal(c))/abs(testCase.TestData.epi.kspace.samples.signal(c));
verifyEqual(testCase, ratio, exp(-params.echoTime/params.t2star), RelTol=1e-6);
end

function testMatrixInputs(testCase)
params = testCase.TestData.params;
params.imageFile = checkerboard(10, 9, 9) > 0.5;
params.t2star    = 50*ones(180);
result = kspaceSimulate(params);
verifySize(testCase, result.recon, [90 90]);
end

function testFieldErrorTypesRun(testCase)
params = testCase.TestData.params;
for fieldErrorType = ["local offset", "random offset", "random lowpass", "x gradient", ...
        "y gradient", "dc offset", "map"]
    params.fieldErrorType = fieldErrorType;
    sim = kspaceDerivedParams(params);
    fieldError = kspaceFieldErrorMap(sim, kspacePixelPositions(sim));
    verifySize(testCase, fieldError, sim.nObjectPixels*[1 1]);
    verifyTrue(testCase, all(isfinite(fieldError(:))), fieldErrorType);
end
end

function testUnknownParameterIsAnError(testCase)
params = testCase.TestData.params;
params.noiseType = "none";   % old name for fieldErrorType
verifyError(testCase, @() kspaceSimulate(params), "kspace:unknownParameter");
try
    kspaceSimulate(params);
catch err
    verifySubstring(testCase, err.message, "fieldErrorType");
end
end

function testMissingParametersTakeDefaults(testCase)
params.fieldErrorType = "none";
sim = kspaceDerivedParams(params);
verifyEqual(testCase, sim.nPixels, 90);
end

function testSecondsWarning(testCase)
params = testCase.TestData.params;
params.t2star = 0.05;   % looks like seconds
verifyWarning(testCase, @() kspaceDerivedParams(params), "kspace:unitsLookLikeSeconds");
end

function testDialogRoundTrip(testCase)
stubFolder = fullfile(fileparts(mfilename("fullpath")), "dialogStub");
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(stubFolder));

params = kspaceDefaultParams();
[returned, ok] = kspaceParamsDialog(params);
verifyTrue(testCase, ok);
verifyEqual(testCase, returned, params);

% A matrix that the dialog cannot show is passed through unchanged
params.t2star = 50*ones(180);
returned = kspaceParamsDialog(params);
verifyEqual(testCase, returned.t2star, params.t2star);
end

function testPlotting(testCase)
f = figure(Visible="off");
testCase.addTeardown(@() close(f));
params = testCase.TestData.params;
params.showProgress = true;
kspaceSimulate(params, Figure=f, ProgressInterval=4000);
params.sequenceType = "spiral";
params.showProgress = false;
kspaceSimulate(params, Figure=f);
handles = getappdata(f, "kspaceHandles");
verifyTrue(testCase, isvalid(handles.recon));
end
