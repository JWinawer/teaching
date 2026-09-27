function [gradients, kspace] = kspaceMakePulseSequence(sim)
% Get gradients and expected kspace locations as function of time
%
%   [gradients, kspace] = kspaceMakePulseSequence(sim)
%
% Input
%   sim - SI parameters from kspaceDerivedParams. Uses sim.sequenceType
%         ("epi" or "spiral"), sim.echoTime and sim.dt.
%
% Output
%   gradients - Gradient sequence, with fields
%     x, y      - k-space step per sample along x and y, cycles per metre.
%                 Multiply by sim.gx to get the gradient in tesla per metre.
%     T         - Duration of each step, in dwell times (usually 1).
%     delay     - Wait between excitation and the start of the readout, in
%                 dwell times. Chosen so that the centre of k-space is sampled
%                 at exactly the echo time.
%     centerIdx - Index of the sample at the centre of k-space.
%     shotStart - true for the first sample of each new shot (multi-shot
%                 spirals). The spins are reset there to their state after
%                 the delay, as after a new excitation.
%   kspace    - k-space positions and empty data, from
%               kspaceInitializeMatrices.
%
% Winawer, Vistasoft, 2009

switch lower(sim.sequenceType)
    case "spiral"
        [gx, gy, T, shotStart] = kspaceSpiral(sim);
    case "epi"
        [gx, gy, T, shotStart] = kspaceEPI(sim);
    otherwise
        error("kspace:unknownSequence", ...
            "Unknown sequence type ""%s"". Use ""epi"" or ""spiral"".", sim.sequenceType);
end

% The echo time is defined as the time from excitation to the centre of
% k-space. k-space position is the running sum of the steps, so find the
% sample closest to the centre during the first shot, and the time taken to
% get there. (Later shots start from a new excitation, see shotStart.)
kx = cumsum(gx.*T);
ky = cumsum(gy.*T);
firstShot = 1:find([shotStart(2:end) true], 1);
[~, centerIdx] = min(kx(firstShot).^2 + ky(firstShot).^2);
timeToCenter = sum(T(1:centerIdx))*sim.dt;

delay = (sim.echoTime - timeToCenter)/sim.dt;
if delay < 0
    error("kspace:echoTimeTooShort", ...
        "Echo time %.1f ms is too short. This readout takes %.1f ms to reach the centre of k-space. " + ...
        "Set echoTime to at least %.1f ms, or raise the bandwidth to shorten the readout.", ...
        sim.echoTime*1e3, timeToCenter*1e3, ceil(timeToCenter*1e4)/10);
end

gradients.x         = gx;
gradients.y         = gy;
gradients.T         = T;
gradients.delay     = delay;
gradients.centerIdx = centerIdx;
gradients.shotStart = shotStart;

% Initialize kspace matrices
kspace = kspaceInitializeMatrices(sim, gradients);

end
