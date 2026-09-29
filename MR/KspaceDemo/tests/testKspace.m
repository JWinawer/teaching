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
% Pressing OK without changing anything returns the same settings
params = kspaceDefaultParams();
[returned, ok] = kspaceParamsDialog(params, TestFcn=@(dialog) press(dialog, "OK"));
verifyTrue(testCase, ok);
verifyEqual(testCase, returned, params);

% A matrix that the dialog cannot show is passed through unchanged
params.t2star = 50*ones(180);
returned = kspaceParamsDialog(params, TestFcn=@(dialog) press(dialog, "OK"));
verifyEqual(testCase, returned.t2star, params.t2star);
end

function testDialogChangesAndCancel(testCase)
params = kspaceDefaultParams();

% Change a drop-down, a checkbox and a number, then press OK
[returned, ok] = kspaceParamsDialog(params, TestFcn=@editAndAccept);
verifyTrue(testCase, ok);
verifyEqual(testCase, returned.sequenceType, "spiral");
verifyEqual(testCase, returned.progressDisplay, "point");
verifyEqual(testCase, returned.echoTime, 55);

% Cancel returns ok = false and the settings unchanged
[returned, ok] = kspaceParamsDialog(params, TestFcn=@editAndCancel);
verifyFalse(testCase, ok);
verifyEqual(testCase, returned, params);
end

function editAndAccept(dialog)
% Change a drop-down, a checkbox and a number, then press OK
setControl(dialog, "sequenceType", "spiral");
setControl(dialog, "progressDisplay", "point");
setControl(dialog, "echoTime", 55);
press(dialog, "OK");
end

function editAndCancel(dialog)
% Change a number, then press Cancel
setControl(dialog, "echoTime", 99);
press(dialog, "Cancel");
end

function setControl(dialog, name, value)
% Set the dialog control for one parameter, as a user would
control = findobj(dialog, Tag=name);
control.Value = value;
end

function press(dialog, buttonName)
% Press a dialog button, as a click would
button = findobj(dialog, Tag=buttonName);
button.ButtonPushedFcn(button, []);
end

function testPlotting(testCase)
f = figure(Visible="off");
testCase.addTeardown(@() close(f));
params = testCase.TestData.params;
params.progressDisplay = "line";
kspaceSimulate(params, Figure=f, ProgressInterval=4000);
params.sequenceType = "spiral";
params.progressDisplay = "final";
kspaceSimulate(params, Figure=f);
handles = getappdata(f, "kspaceHandles");
verifyTrue(testCase, isvalid(handles.recon));
end

function testSaveMovie(testCase)
f = figure(Visible="off", Position=[0 0 800 600]);
testCase.addTeardown(@() close(f));
params = testCase.TestData.params;
result = kspaceSimulate(params, Figure=f, SaveMovie=true, Title="test movie", ...
    ProgressInterval=2000, MovieFrameRate=5);
testCase.addTeardown(@() delete(result.movieFile));

verifyTrue(testCase, isfile(result.movieFile));
% 8100 samples, a frame every 2000 gives 4 frames, then the last frame is
% held for 1 s (5 frames)
reader = VideoReader(result.movieFile);
verifyEqual(testCase, reader.NumFrames, 4 + 5);
end

function testPointByPointDisplay(testCase)
% Point mode redraws after every sample. For speed this test uses a small
% image: 16 x 16 pixels, so 256 samples.
f = figure(Visible="off");
testCase.addTeardown(@() close(f));
params = testCase.TestData.params;
params.FOV             = 32;
params.objectSize      = 32;
params.pixelSize       = 2;
params.echoTime        = 10;
params.progressDisplay = "point";
for sequence = ["epi", "spiral"]
    params.sequenceType = sequence;
    result = kspaceSimulate(params, Figure=f);
    verifySize(testCase, result.recon, [16 16]);
end
end

function testProgressDisplayChoices(testCase)
params = testCase.TestData.params;
params.progressDisplay = "sometimes";
verifyError(testCase, @() kspaceDerivedParams(params), "kspace:unknownProgressDisplay");
params = rmfield(testCase.TestData.params, "progressDisplay");
params.showProgress = true;   % old name
verifyError(testCase, @() kspaceDerivedParams(params), "kspace:unknownParameter");
end

function testClosingFigureStopsDrawing(testCase)
% Closing the figure partway through a run stops the drawing but still
% finishes the simulation
f = figure(Visible="off");
params = testCase.TestData.params;
params.progressDisplay = "line";
% Close the figure 1 s into the run, which takes several seconds
closer = timer(StartDelay=1, TimerFcn=@(~, ~) close(f));
testCase.addTeardown(@() delete(closer));
start(closer);
result = kspaceSimulate(params, Figure=f);
verifyFalse(testCase, isvalid(f), "The figure was not closed during the run, so this test did not test anything");
verifyEqual(testCase, result.t, numel(result.gradients.nDwells));
verifyGreaterThan(testCase, corr(result.recon(:), ...
    reshape(imresize(result.object.image, [90 90]), [], 1)), 0.98);
end

function testDialogFitsItsContents(testCase)
% The window is tall enough to show every row, including the buttons
kspaceParamsDialog(kspaceDefaultParams(), TestFcn=@(dialog) checkDialogHeight(testCase, dialog));
end

function checkDialogHeight(testCase, dialog)
% Compare the window height with the space its rows need, then press OK
drawnow
grid   = dialog.Children(1);
nRows  = numel(grid.RowHeight);
needed = sum([grid.RowHeight{:}]) + (nRows - 1)*grid.RowSpacing + grid.Padding(2) + grid.Padding(4);
verifyGreaterThanOrEqual(testCase, dialog.Position(4), needed);
press(dialog, "OK");
end
