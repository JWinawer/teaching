function result = kspaceSimulate(params, options)
% Simulate an MRI acquisition and reconstruct the image, without the dialog.
%
%   result = kspaceSimulate()
%   result = kspaceSimulate(params)
%   result = kspaceSimulate(params, Figure=f)
%
% Simulates the scanner measuring k-space one sample at a time, then
% reconstructs the image. Use this in scripts, for example to sweep a
% parameter. kspaceDemo is the same simulation with a dialog in front.
%
% Inputs
%   params           - settings in everyday units (default:
%                      kspaceDefaultParams()). Missing fields take their
%                      defaults. Not changed.
%   Figure           - (optional) figure to plot into. By default nothing is
%                      plotted.
%   ProgressInterval - (optional) with params.showProgress true and a Figure,
%                      redraw every this many samples. Default: one EPI line.
%
% Output, a struct with fields
%   recon      - reconstructed image (magnitude), nPixels x nPixels
%   params     - the input settings
%   sim        - the settings in SI units, plus derived values
%                (kspaceDerivedParams)
%   object     - the simulated object (kspaceLoadObject)
%   xygrid     - pixel positions, meters
%   fieldError - B0 field error at each pixel, tesla
%   gradients  - the pulse sequence (kspaceMakePulseSequence)
%   kspace     - the measured samples (kspace.samples) and gridded k-space
%                (kspace.grid)
%   spins      - the final spin state
%   t          - number of samples measured so far
%
% Example: how does the EPI image shift with a uniform field offset?
%   params = kspaceDefaultParams();
%   params.fieldErrorType = "dc offset";
%   params.fieldErrorPpm  = 1;
%   result = kspaceSimulate(params);
%   imagesc(result.recon); axis image; colormap gray
%
% See also kspaceDefaultParams, kspaceDemo, kspaceShowPlots

arguments
    params (1,1) struct = kspaceDefaultParams()
    options.Figure = []
    options.ProgressInterval (1,1) double {mustBePositive, mustBeInteger} = 1
end

kspaceCheckPaths();

sim        = kspaceDerivedParams(params);
object     = kspaceLoadObject(sim);
xygrid     = kspacePixelPositions(sim);
fieldError = kspaceFieldErrorMap(sim, xygrid);
[gradients, kspace] = kspaceMakePulseSequence(sim);

% The spin state just after the wait before the readout. For EPI the steps
% repeat, so they are worked out once in advance, which saves a lot of time.
spins = kspaceInitializeSpins(sim, gradients, xygrid, fieldError);

result.recon      = [];
result.params     = params;
result.sim        = sim;
result.object     = object;
result.xygrid     = xygrid;
result.fieldError = fieldError;
result.gradients  = gradients;
result.kspace     = kspace;
result.spins      = spins;
result.t          = 0;

hasFigure    = ~isempty(options.Figure);
showProgress = hasFigure && sim.showProgress;
interval     = options.ProgressInterval;
if showProgress && interval == 1
    interval = sim.nPixels;
end
if hasFigure && ~showProgress
    waitHandle = waitbar(0, "Simulating Fourier imaging. Please wait...");
    cleanup = onCleanup(@() delete(waitHandle));
end

nSamples = length(gradients.nDwells);
waitbarStep = round(nSamples/10);
for t = 1:nSamples
    % Rotate (and decay) every spin by this step. The spin state is the
    % pattern the object is multiplied by to get this sample.
    spins = kspaceStepFactor(sim, gradients, xygrid, fieldError, spins, t);
    spins.state = spins.state .* spins.step;

    % Measure one point in k-space
    kspace = kspaceMeasureSample(kspace, t, object, spins, sim);

    if showProgress && mod(t, interval) == 0 && t < nSamples
        [result.kspace, result.recon] = kspaceRecon(kspace, sim);
        result.spins = spins;
        result.t     = t;
        kspaceShowPlots(options.Figure, result);
    elseif hasFigure && ~showProgress && mod(t, waitbarStep) == 0
        waitbar(t/nSamples, waitHandle);
    end
end

[result.kspace, result.recon] = kspaceRecon(kspace, sim);
result.spins = spins;
result.t     = nSamples;

if hasFigure
    kspaceShowPlots(options.Figure, result);
end

end
