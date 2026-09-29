function result = kspaceSimulate(params, options)
% Simulate an MRI acquisition and reconstruct the image, without the dialog.
%
%   result = kspaceSimulate()
%   result = kspaceSimulate(params)
%   result = kspaceSimulate(params, Figure=f)
%   result = kspaceSimulate(params, SaveMovie=true, Title="EPI with a field error")
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
%   ProgressInterval - (optional) with a Figure, redraw every this many
%                      samples while k-space fills. Default: set by
%                      params.progressDisplay (one EPI line for "line", every
%                      sample for "point").
%   SaveMovie        - (optional) true to save a movie of k-space filling, as
%                      an mp4 file in movies/. Default false. If
%                      params.progressDisplay is "final", the movie shows one
%                      frame per EPI line. Makes a figure if none is given. Saving is slower than watching, because each
%                      frame has to be captured from the screen.
%   Title            - (optional) name for the movie file. Default: the
%                      sequence and field error type.
%   MovieFrameRate   - (optional) playback speed of the movie, frames per
%                      second. Default 6. The last frame is held for 1 s.
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
%   movieFile  - path of the saved movie, or "" if none was saved
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
    options.ProgressInterval double {mustBeScalarOrEmpty, mustBePositive, mustBeInteger} = []
    options.SaveMovie (1,1) logical = false
    options.Title (1,1) string = ""
    options.MovieFrameRate (1,1) double {mustBePositive} = 6
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
result.movieFile  = "";

% A movie shows k-space filling, so it needs a figure and the progress
% display
figureHandle = options.Figure;
if options.SaveMovie && isempty(figureHandle)
    figureHandle = figure(Name="k-space demo", NumberTitle="off");
end

% How often to redraw while k-space fills. A movie of only the final image
% would be one frame, so a movie shows at least one frame per line.
progressDisplay = sim.progressDisplay;
if options.SaveMovie && progressDisplay == "final"
    progressDisplay = "line";
end
hasFigure    = ~isempty(figureHandle);
showProgress = hasFigure && (progressDisplay ~= "final");
interval     = options.ProgressInterval;
if isempty(interval)
    if progressDisplay == "point"
        interval = 1;
    else
        interval = sim.nPixels;
    end
end

% Rebuilding a spiral image takes about 0.2 s, far too long to do after
% every sample, so the image is rebuilt at most once per turn of the
% spiral. The spin pattern and k-space position still update every time.
reconInterval = interval;
if sim.sequenceType == "spiral"
    reconInterval = max(interval, sim.nPixels);
end
if hasFigure && ~showProgress
    waitHandle = waitbar(0, "Simulating Fourier imaging. Please wait...");
    cleanup = onCleanup(@() delete(waitHandle));
end

nSamples = length(gradients.nDwells);
waitbarStep = round(nSamples/10);

if options.SaveMovie
    nUpdates = floor((nSamples - 1)/interval);
    holdFrames = ceil(options.MovieFrameRate);   % hold the last frame for 1 s
    frames(nUpdates + holdFrames) = struct("cdata", [], "colormap", []);
    frameCount = 0;
end
for t = 1:nSamples
    % Rotate (and decay) every spin by this step. The spin state is the
    % pattern the object is multiplied by to get this sample.
    spins = kspaceStepFactor(sim, gradients, xygrid, fieldError, spins, t);
    spins.state = spins.state .* spins.step;

    % Measure one point in k-space
    kspace = kspaceMeasureSample(kspace, t, object, spins, sim);

    if showProgress && ~isvalid(figureHandle)
        % The figure was closed: stop drawing, and finish without plots
        showProgress = false;
        hasFigure    = false;
    end

    if showProgress && mod(t, interval) == 0 && t < nSamples
        if mod(t, reconInterval) == 0 || isempty(result.recon)
            [result.kspace, result.recon] = kspaceRecon(kspace, sim);
        end
        result.kspace.samples = kspace.samples;
        result.spins = spins;
        result.t     = t;
        kspaceShowPlots(figureHandle, result, DrawEveryUpdate=(progressDisplay == "point"));
        if options.SaveMovie
            frameCount = frameCount + 1;
            frames(frameCount) = getframe(figureHandle);
        end
    elseif hasFigure && ~showProgress && mod(t, waitbarStep) == 0 && isvalid(waitHandle)
        waitbar(t/nSamples, waitHandle);
    end
end

[result.kspace, result.recon] = kspaceRecon(kspace, sim);
result.spins = spins;
result.t     = nSamples;

hasFigure = hasFigure && isvalid(figureHandle);
if hasFigure
    kspaceShowPlots(figureHandle, result);
end

if options.SaveMovie && ~hasFigure
    warning("kspace:movieNotSaved", "The figure was closed before the run finished, so no movie was saved.");
elseif options.SaveMovie
    lastFrame = getframe(figureHandle);
    frames(frameCount + (1:holdFrames)) = lastFrame;
    movieName = options.Title;
    if strlength(movieName) == 0
        movieName = "kspace " + sim.sequenceType + " " + sim.fieldErrorType;
    end
    result.movieFile = kspaceSaveMovie(frames, movieName, options.MovieFrameRate);
end

end
