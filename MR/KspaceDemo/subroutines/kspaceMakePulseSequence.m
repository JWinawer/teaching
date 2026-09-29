function [gradients, kspace] = kspaceMakePulseSequence(sim)
% Make the pulse sequence: the k-space step taken at each sample.
%
%   [gradients, kspace] = kspaceMakePulseSequence(sim)
%
% Inputs
%   sim - SI parameters from kspaceDerivedParams. Uses sim.sequenceType
%         ("epi" or "spiral"), sim.echoTime and sim.dt.
%
% Outputs
%   gradients - the sequence, with fields
%     dkx, dky    - k-space step per sample along x and y, cycles/m.
%                   Multiply by sim.gradientPerStep to get the gradient in T/m.
%     nDwells     - duration of each step, in dwell times (usually 1)
%     delayDwells - wait between excitation and the start of the readout, in
%                   dwell times. Chosen so that the center of k-space is
%                   sampled at exactly the echo time.
%     centerIndex - index of the sample at the center of k-space
%   kspace    - k-space positions and empty data (kspaceInitializeData)
%
% See also kspaceEPI, kspaceSpiral, kspaceInitializeData

switch sim.sequenceType
    case "spiral"
        [dkx, dky, nDwells] = kspaceSpiral(sim);
    case "epi"
        [dkx, dky, nDwells] = kspaceEPI(sim);
    otherwise
        error("kspace:unknownSequence", ...
            "Unknown sequence type ""%s"". Use ""epi"" or ""spiral"".", sim.sequenceType);
end

% The echo time is defined as the time from excitation to the center of
% k-space. k-space position is the running sum of the steps, so find the
% first sample closest to the center, and the time taken to get there.
kx = cumsum(dkx.*nDwells);
ky = cumsum(dky.*nDwells);
[~, centerIndex] = min(kx.^2 + ky.^2);
timeToCenter = sum(nDwells(1:centerIndex))*sim.dt;

delayDwells = (sim.echoTime - timeToCenter)/sim.dt;
if delayDwells < 0
    msPerS = 1e3;
    error("kspace:echoTimeTooShort", ...
        "Echo time %.1f ms is too short. This readout takes %.1f ms to reach the center of k-space. " + ...
        "Set echoTime to at least %.1f ms, or raise the bandwidth to shorten the readout.", ...
        sim.echoTime*msPerS, timeToCenter*msPerS, ceil(timeToCenter*msPerS*10)/10);
end

gradients.dkx         = dkx;
gradients.dky         = dky;
gradients.nDwells     = nDwells;
gradients.delayDwells = delayDwells;
gradients.centerIndex = centerIndex;

kspace = kspaceInitializeData(sim, gradients);

end
