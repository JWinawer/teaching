function [M, parameters] = animateSpins(parameters, figureHandle, titleString, saveMovieFlag)
% Animate a population of spins and the bulk magnetization they sum to.
%
%   [M, parameters] = animateSpins(parameters, figureHandle, titleString, saveMovieFlag)
%
% All inputs are optional. M is returned as nsteps x 3, the bulk
% magnetization at each time step in units of the equilibrium magnetization,
% so that you can plot or analyze a run after it finishes. parameters is
% returned with the derived fields added (see spinsAddDerivedParameters).
%
% See also SPINSDEFAULTPARAMS, S_SPINSTOBULKM

if ~exist('parameters', 'var')   || isempty(parameters),   parameters   = spinsDefaultParams(); end
if ~exist('figureHandle', 'var') || isempty(figureHandle), figureHandle = figure(); end
if ~exist('titleString', 'var'),  titleString  = ''; end
if ~exist('saveMovieFlag', 'var') || isempty(saveMovieFlag), saveMovieFlag = false; end

% Derived parameters
parameters = spinsAddDerivedParameters(parameters);

if saveMovieFlag
    MOV(parameters.nsteps) = struct('cdata', [], 'colormap', []);
end

% Set up figure
[figureHandle, tH] = spinsSetUpFigure(figureHandle, titleString);

% Initialize spins at thermal equilibrium
[Spins, B_dist] = initializeSpins(parameters);

% Scale for the bulk magnetization plots. Use the expected equilibrium
% magnetization rather than the realized one, so that any wobble away from
% Mz = 1 is the honest shot noise of simulating only nspins spins instead of
% the ~10^19 in a real voxel. When k is 0 there is no field and no
% equilibrium magnetization, so fall back to nspins; the bulk vector then
% correctly shows up as a tiny residual near the origin.
if B_dist.Mz > 0
    Mscale = parameters.nspins * B_dist.Mz;
else
    Mscale = parameters.nspins;
end

M = zeros(parameters.nsteps, 3);

% Dynamics
for stepnum = 1:parameters.nsteps

    % Larmor precession
    Spins = rotateB0(Spins, parameters);

    % B1 flip
    Spins = rotateB1(Spins, parameters, stepnum);

    % T2 relaxation
    Spins = relaxationTransverse(Spins, parameters);

    % T1 relaxation
    Spins = relaxationLongitudinal(Spins, parameters, B_dist);

    % Bulk magnetization
    M(stepnum,:) = sum(Spins)/Mscale;

    % Plot instantaneous spins
    nexttile(tH, 1, [3 3]);
    plotSpins(Spins, M(stepnum,:));

    % Plot bulk magnetization
    nexttile(tH, 4);
    plotBulk(parameters.t, M(1:stepnum,:))

    % Plot spin angle histograms
    nexttile(tH, 8);
    plotHistogram(Spins, 'Azimuth');

    nexttile(tH, 12);
    plotHistogram(Spins, 'Elevation');

    % limitrate lets the renderer drop frames to keep up, which is what we
    % want on screen; when saving a movie every frame has to be real.
    if saveMovieFlag
        drawnow
        MOV(stepnum) = getframe(figureHandle);
    else
        drawnow limitrate
    end
end

if saveMovieFlag
    movieDir = fullfile(fileparts(mfilename('fullpath')), 'movies');
    if ~isfolder(movieDir), mkdir(movieDir); end

    % Keep the file name to characters that are safe on every platform
    name = regexprep(titleString, '[^\w \-]', '');
    if isempty(strtrim(name)), name = 'spins'; end

    v = VideoWriter(fullfile(movieDir, name), 'MPEG-4');
    v.FrameRate = 6;
    open(v);
    writeVideo(v, MOV);
    close(v);
    fprintf('Wrote %s\n', fullfile(movieDir, [name '.mp4']));
end

end
