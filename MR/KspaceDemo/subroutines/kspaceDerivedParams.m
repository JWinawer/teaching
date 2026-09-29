function sim = kspaceDerivedParams(params)
% Check the parameters, convert them to SI units, and add derived values.
%
%   sim = kspaceDerivedParams(params)
%
% params is in everyday units (see kspaceDefaultParams). Fields missing from
% params take their defaults, and a field that is not a known parameter is
% an error, so a typo or an old parameter name cannot be silently ignored.
%
% sim holds the same settings in SI units (m, s, Hz, T), plus the values
% derived from them. The simulation functions all use sim. params itself is
% never changed, so it can be passed back in to run again.
%
% Fields of sim that are not simply converted from params
%   nPixels            - reconstructed pixels per side
%   nObjectPixels      - simulated object pixels per side
%   dt                 - dwell time, the time between samples, s
%   gamma              - gyromagnetic ratio of hydrogen, rad/s/T
%   gradientPerStep    - gradient that moves one cycle per meter per dwell
%                        time, T/m
%   fieldErrorFraction - fieldErrorPpm as a fraction of B0
%
% See also kspaceDefaultParams, kspaceSimulate

params = checkFields(params);

mm = 1e-3;
ms = 1e-3;

% Gyromagnetic ratio of hydrogen, in radians per second per tesla
gamma = 42.58e6*2*pi;

% Field of view is rounded so that the number of reconstructed pixels is
% even. The number of pixels must be even for the EPI trajectory.
pixelSize = params.pixelSize*mm;
FOV       = round(params.FOV*mm/pixelSize/2)*pixelSize*2;
nPixels   = round(FOV/pixelSize);

objectSize      = params.objectSize*mm;
objectPixelSize = params.objectPixelSize*mm;
nObjectPixels   = round(objectSize/objectPixelSize);

% T2* in seconds. A map is resized to the simulated object grid.
t2star = params.t2star*ms;
if ~isscalar(t2star)
    t2star = imresize(t2star, [nObjectPixels nObjectPixels], "nearest");
end

% Dwell time is the time between successive k-space samples
bandwidth = params.bandwidth*1e3;
dt        = 1/bandwidth;

% Gradient strength per unit step. The maths:
%   gradientPerStep*gamma*dt = 2*pi
% So one dwell time at this gradient adds a phase difference of 2*pi per
% meter. The pulse sequence functions scale this by the k-space step they
% want per sample (in cycles per meter), which gives a gradient in T/m.
gradientPerStep = 2*pi/(gamma*dt);

sim.imageFile          = params.imageFile;
sim.sequenceType       = lower(string(params.sequenceType));
sim.fieldErrorType     = lower(string(params.fieldErrorType));
sim.fieldErrorFraction = params.fieldErrorPpm*1e-6;
sim.pixelSize          = pixelSize;
sim.FOV                = FOV;
sim.nPixels            = nPixels;
sim.objectSize         = objectSize;
sim.objectPixelSize    = objectPixelSize;
sim.nObjectPixels      = nObjectPixels;
sim.bandwidth          = bandwidth;
sim.dt                 = dt;
sim.echoTime           = params.echoTime*ms;
sim.t2star             = t2star;
sim.B0                 = params.B0;
sim.gamma              = gamma;
sim.gradientPerStep    = gradientPerStep;
sim.progressDisplay    = lower(string(params.progressDisplay));

end

function params = checkFields(params)
% Fill in missing fields from the defaults, and reject unknown ones

defaults = kspaceDefaultParams();

% Names used before September 2026. Listed so the error can say what the new
% name is.
oldNames = struct("imfile", "imageFile", "noiseType", "fieldErrorType", ...
    "noiseScale", "fieldErrorPpm", "res", "pixelSize", "imSize", "objectSize", ...
    "imRes", "objectPixelSize", "loop", "keepDialogOpen", "showProgress", "progressDisplay");

given   = string(fieldnames(params))';
unknown = setdiff(given, string(fieldnames(defaults))');
if ~isempty(unknown)
    hints = strings(size(unknown));
    for ii = 1:numel(unknown)
        if isfield(oldNames, unknown(ii))
            hints(ii) = sprintf(" (now called %s)", oldNames.(unknown(ii)));
        end
    end
    error("kspace:unknownParameter", "Unknown parameter: %s. See kspaceDefaultParams for the list.", ...
        join(unknown + hints, ", "));
end

progressChoices = ["final", "line", "point"];
if isfield(params, "progressDisplay") && ~ismember(lower(string(params.progressDisplay)), progressChoices)
    error("kspace:unknownProgressDisplay", "progressDisplay must be one of: %s.", join(progressChoices, ", "));
end

missing = setdiff(string(fieldnames(defaults))', given);
for name = missing
    params.(name) = defaults.(name);
end

% Catch times that look like they were entered in seconds
for name = ["echoTime", "t2star"]
    value = params.(name);
    if all(isfinite(value(:))) && any(value(:) < 1)
        warning("kspace:unitsLookLikeSeconds", ...
            "%s is under 1 ms. Times are in ms. Did you enter seconds?", name);
    end
end

end
