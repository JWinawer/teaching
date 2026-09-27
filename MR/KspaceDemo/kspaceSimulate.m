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
%                      kspaceDefaultParams()). Not changed.
%   Figure           - (optional) figure to plot into. By default nothing is
%                      plotted.
%   ProgressInterval - (optional) with params.showProgress true and a Figure,
%                      redraw every this many samples. Default: one EPI line.
%
% Output, a struct with fields
%   recon     - reconstructed image (magnitude), sim.freq x sim.freq
%   params    - the input settings
%   sim       - the settings in SI units, plus derived values
%               (kspaceDerivedParams)
%   im        - the simulated object (kspaceGetImage)
%   xygrid    - pixel positions, metres
%   b0noise   - B0 field error at each pixel, tesla
%   gradients - the pulse sequence (kspaceMakePulseSequence)
%   kspace    - the measured samples (kspace.vector) and gridded k-space
%               (kspace.grid)
%   spins     - the final spin state
%   t         - number of samples measured so far
%
% Example: how does the EPI image shift with a uniform field offset?
%   params = kspaceDefaultParams();
%   params.noiseType = "dc offset";
%   params.noiseScale = 1;             % ppm
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

sim       = kspaceDerivedParams(params);
im        = kspaceGetImage(sim);
xygrid    = kspaceGrid(sim);
b0noise   = kspaceGetB0Noise(sim, xygrid);
[gradients, kspace] = kspaceMakePulseSequence(sim);

% The spin state just after the wait before the readout. For EPI the steps
% repeat, so they are computed once in advance, which saves a lot of time.
spins = kspacePreCompute(sim, gradients, xygrid, b0noise);

result.recon     = [];
result.params    = params;
result.sim       = sim;
result.im        = im;
result.xygrid    = xygrid;
result.b0noise   = b0noise;
result.gradients = gradients;
result.kspace    = kspace;
result.spins     = spins;
result.t         = 0;

hasFigure    = ~isempty(options.Figure);
showProgress = hasFigure && sim.showProgress;
interval     = options.ProgressInterval;
if showProgress && interval == 1
    interval = sim.freq;
end
if hasFigure && ~showProgress
    waitHandle = waitbar(0, "Simulating Fourier imaging. Please wait...");
    cleanup = onCleanup(@() delete(waitHandle));
end

nSamples = length(gradients.T);
waitbarStep = round(nSamples/10);
for t = 1:nSamples
    if gradients.shotStart(t)
        % A new shot starts from a new excitation
        spins.total = spins.afterDelay;
    else
        % Rotate (and decay) every spin by this step
        spins = kspaceComputeOnePoint(sim, gradients, xygrid, b0noise, spins, t);
        spins = kspaceGetCurrentBasisFunctions(spins);
    end

    % Measure one point in k-space
    kspace = kspaceGetCurrentSignal(kspace, t, im, spins, sim);

    if showProgress && mod(t, interval) == 0 && t < nSamples
        [result.kspace, result.recon] = reconstruct(kspace, sim);
        result.spins = spins;
        result.t     = t;
        kspaceShowPlots(options.Figure, result);
    elseif hasFigure && ~showProgress && mod(t, waitbarStep) == 0
        waitbar(t/nSamples, waitHandle);
    end
end

[result.kspace, result.recon] = reconstruct(kspace, sim);
result.spins = spins;
result.t     = nSamples;

if hasFigure
    kspaceShowPlots(options.Figure, result);
end

end

function [kspace, recon] = reconstruct(kspace, sim)
% Grid the samples and inverse Fourier transform them to get the image
kspace = kspaceRecon(kspace, sim);
recon  = abs(ifft2(kspace.grid.real + 1i*kspace.grid.imag));
end
