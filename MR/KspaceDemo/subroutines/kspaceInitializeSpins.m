function spins = kspaceInitializeSpins(sim, gradients, xygrid, fieldError)
% Set the spins to their state at the start of the readout, and work out
% the steps in advance if the sequence repeats itself.
%
%   spins = kspaceInitializeSpins(sim, gradients, xygrid, fieldError)
%
% Outputs
%   spins.state     - complex state of every spin after the wait before the
%                     readout. Its real and imaginary parts are the cosine and
%                     sine patterns that the object is multiplied by to get
%                     each k-space sample.
%   spins.stepTable - the distinct steps, nObjectPixels x nObjectPixels x
%                     nDistinct, and spins.stepIndex, which one each sample
%                     uses. Only set if there are 20 or fewer distinct steps
%                     (true for EPI), since otherwise it saves little and
%                     uses a lot of memory.
%
% See also kspaceStepFactor, kspaceSimulate

% Effect of the wait between excitation and the start of the readout
spins = kspaceStepFactor(sim, gradients, xygrid, fieldError, struct(), 0);
spins.state = spins.step;

% Find the distinct steps. For EPI there are only a handful.
[distinctSteps, firstUse, stepIndex] = unique( ...
    [gradients.dky' gradients.dkx' gradients.nDwells'], "rows");
maxDistinct = 20;
nDistinct   = size(distinctSteps, 1);
if nDistinct > maxDistinct
    return
end

stepTable = zeros([size(xygrid.x) nDistinct]);
for ii = 1:nDistinct
    oneStep = kspaceStepFactor(sim, gradients, xygrid, fieldError, struct(), firstUse(ii));
    stepTable(:,:,ii) = oneStep.step;
end
spins.stepTable = stepTable;
spins.stepIndex = stepIndex;

end
