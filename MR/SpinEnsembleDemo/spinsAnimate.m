function [M, params, movieFile] = spinsAnimate(params, options)
% Animate a population of spins and the bulk magnetization they sum to.
%
%   spinsAnimate()
%   [M, params, movieFile] = spinsAnimate(params)
%   [M, params, movieFile] = spinsAnimate(params, Figure=f, Title="...", SaveMovie=true)
%
% Inputs
%   params    - settings (default: spinsDefaultParams()). Missing fields take
%               their defaults.
%   Figure    - (optional) figure to draw in. Default: a new figure.
%   Title     - (optional) title for the figure, and the movie file name.
%   SaveMovie - (optional) true to save the animation as an mp4 file in
%               movies/. Default false. Saving is much slower than watching.
%
% Outputs
%   M         - bulk magnetization, nSteps x 3 (Mx, My, Mz), in units of the
%               equilibrium magnetization
%   params    - the settings, with derived fields added (spinsDerivedParams).
%               params.t is the time of each step, in ms.
%   movieFile - path of the saved movie, or "" if none was saved
%
% params.frameRate sets the playback speed, on screen and in the movie. On
% screen the frames are paced to that rate, but redrawing can be uneven. For
% a smooth version, save a movie and play that back instead:
%
%   [~, ~, movieFile] = spinsAnimate(params, Title="my title", SaveMovie=true);
%   implay(movieFile);   % needs the Image Processing Toolbox
%
% See also spinsSimulate, spinsDefaultParams

arguments
    params (1,1) struct = spinsDefaultParams()
    options.Figure = []
    options.Title (1,1) string = ""
    options.SaveMovie (1,1) logical = false
end

spinsCheckPaths();
params = spinsDerivedParams(params);

figureHandle = options.Figure;
if isempty(figureHandle)
    figureHandle = figure();
end
titleText = options.Title;
movieFile = "";

% Frames are paced to this rate on screen. A saved movie is rendered as fast
% as possible and then plays back at this rate.
frameInterval = 1/params.frameRate;

if options.SaveMovie
    frames(params.nSteps) = struct("cdata", [], "colormap", []);
end

layout = spinsSetUpFigure(figureHandle, titleText);

% If the field switches on partway through the run, say so in the title and
% mark the moment on the magnetization plot.
showFieldState = ~all(params.fieldOn);

% With larmor = 0 we are watching in the rotating reference frame, so label
% the transverse axes X' and Y'. With k = 0 there is no field, hence no
% Larmor frequency and no rotating frame, so the axes keep their usual names.
isRotatingFrame = (abs(params.larmor) < eps) && (params.k > 0);

[spins, boltzmann, offsetStep, magnetizationScale] = spinsInitialize(params);

M = zeros(params.nSteps, 3);
frameClock = tic;

for stepIndex = 1:params.nSteps

    % Precession, RF pulse, T2 and T1, in that order
    spins = spinsTimeStep(spins, params, stepIndex, boltzmann, offsetStep);
    M(stepIndex,:) = sum(spins)/magnetizationScale;

    nexttile(layout, 1, [3 3]);
    spinsPlotSphere(spins, M(stepIndex,:), isRotatingFrame);

    nexttile(layout, 4);
    spinsPlotMagnetization(params.t, M(1:stepIndex,:));
    if showFieldState && stepIndex == 1
        % No text label: the panel is too small for one to be legible, and
        % the figure title already says whether the field is on.
        xline(gca, params.fieldOnTime, "--");
    end

    nexttile(layout, 8);
    spinsPlotHistogram(spins, "Azimuth");

    nexttile(layout, 12);
    spinsPlotHistogram(spins, "Elevation");

    if showFieldState
        if params.fieldOn(stepIndex)
            fieldLabel = "B_0 on";
        else
            fieldLabel = "B_0 off";
        end
        layout.Title.String = strtrim(sprintf("%s   (%s)", titleText, fieldLabel));
    end

    drawnow

    if options.SaveMovie
        % No point pacing: the movie carries its own frame rate, so render as
        % fast as the machine allows.
        frames(stepIndex) = getframe(figureHandle);
    else
        % Pace the frames. A step takes only a few milliseconds, so without
        % this the animation races past unevenly and is impossible to follow.
        waitFor = frameInterval - toc(frameClock);
        if waitFor > 0
            pause(waitFor);
        end
        frameClock = tic;
    end
end

if options.SaveMovie
    movieFile = saveMovie(frames, titleText, params.frameRate);
end

end

function movieFile = saveMovie(frames, titleText, frameRate)
% Write the frames to an mp4 file in movies/, named after the title

movieDir = fullfile(fileparts(mfilename("fullpath")), "movies");
if ~isfolder(movieDir)
    mkdir(movieDir);
end

% Keep the file name to characters that are safe on every platform
name = regexprep(titleText, "[^\w \-]", "");
if strlength(strtrim(name)) == 0
    name = "spins";
end

writer = VideoWriter(fullfile(movieDir, name), "MPEG-4");
writer.FrameRate = frameRate;
open(writer);
writeVideo(writer, frames);
close(writer);
movieFile = fullfile(movieDir, name + ".mp4");
fprintf("Wrote %s\n", movieFile);

end
