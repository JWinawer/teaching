function fieldError = kspaceFieldErrorMap(sim, xygrid)
% Make a map of the error in the main field B0, in tesla.
%
%   fieldError = kspaceFieldErrorMap(sim, xygrid)
%
% An error in B0 makes the spins at that place precess slightly too fast or
% too slow. A realistic size is roughly 1 part in 10^6 to 10^7 of B0 across
% most of the brain, and more near air-tissue boundaries.
%
% Inputs
%   sim    - SI parameters (kspaceDerivedParams). Uses sim.fieldErrorType,
%            sim.fieldErrorFraction, sim.B0, sim.nObjectPixels, sim.objectSize
%            and sim.gamma.
%   xygrid - pixel positions, meters (kspacePixelPositions)
%
% fieldErrorType is one of
%   "none"           - a perfect field
%   "local offset"   - a smooth spot, as near an air-filled sinus
%   "random offset"  - independent at every pixel
%   "random lowpass" - smooth, random blobs
%   "x gradient", "y gradient" - a linear change across the image
%   "dc offset"      - the same error everywhere, as if the scanner were
%                      slightly off resonance
%   "map"            - a measured field map (data/b0Lucas.mat, which appears
%                      to be from the Lucas Center at Stanford). Its size is
%                      not scaled by fieldErrorFraction.
%
% See also kspaceDefaultParams, kspaceStepFactor

n = sim.nObjectPixels;
x = xygrid.x;
y = xygrid.y;

% The spatial pattern, with a peak size of 1
switch sim.fieldErrorType
    case "none"
        pattern = zeros(n);
    case {"random offset", "random"}
        pattern = randn(n);
        pattern = pattern/max(pattern(:));
    case "random lowpass"
        blur    = fspecial("gaussian", n, n/16);
        pattern = imfilter(randn(n), blur, "same");
        pattern = pattern/max(pattern(:));
    case {"dc offset", "constant", "uniform"}
        pattern = ones(n);
    case "x gradient"
        pattern = x/max(x(:));
        pattern = pattern - mean(pattern(:));
    case "y gradient"
        pattern = y/max(y(:));
        pattern = pattern - mean(pattern(:));
    case {"local offset", "local"}
        spotCenter = [0.25 0.25]*sim.objectSize;
        spotRadius = 0.01*sim.objectSize;
        inSpot  = sqrt((x - spotCenter(1)).^2 + (y - spotCenter(2)).^2) < spotRadius;
        blur    = fspecial("gaussian", n, n/16);
        pattern = imfilter(double(inSpot), blur, "same");
        pattern = pattern/max(pattern(:));
    case "map"
        % A measured map, in Hz. Convert to tesla and return: it is already
        % in real units, so it is not scaled below.
        dataFolder = fullfile(fileparts(fileparts(mfilename("fullpath"))), "data");
        measured   = load(fullfile(dataFolder, "b0Lucas.mat"));
        fieldError = imresize(measured.b0*2*pi/sim.gamma, [n n]);
        return
    otherwise
        error("kspace:unknownFieldErrorType", ...
            "Unknown fieldErrorType ""%s"". See kspaceDefaultParams for the options.", sim.fieldErrorType);
end

fieldError = pattern*sim.fieldErrorFraction*sim.B0;

end
