function spins = kspaceStepFactor(sim, gradients, xygrid, fieldError, spins, t)
% Work out how every spin changes over one step of the sequence.
%
%   spins = kspaceStepFactor(sim, gradients, xygrid, fieldError, spins, t)
%
% Each simulated pixel is treated as one spin with a complex value. Over each
% step, the spin is multiplied by a small complex factor, spins.step, which
% has two parts:
%   - a rotation (phase change) from the gradients and from any B0 field
%     error at that location
%   - a shrinkage from T2* decay, if sim.t2star is finite
% kspaceSimulate then multiplies the spin state by it.
%
% Inputs
%   sim        - SI parameters (kspaceDerivedParams)
%   gradients  - the sequence (kspaceMakePulseSequence)
%   xygrid     - pixel positions, meters (kspacePixelPositions)
%   fieldError - B0 field error at each pixel, tesla (kspaceFieldErrorMap)
%   spins      - spin state. If spins.stepTable exists, the step is looked
%                up there instead of computed.
%   t          - sample number. t = 0 means the wait between excitation and
%                the start of the readout, when the gradients are off.
%
% Outputs
%   spins      - with spins.step set for this step
%
% See also kspaceInitializeSpins, kspaceSimulate

% If the step was worked out in advance, look it up
if isfield(spins, "stepTable")
    spins.step = spins.stepTable(:,:,spins.stepIndex(t));
    return
end

if t == 0
    % The wait before the readout: gradients off, so the only effects are
    % dephasing from B0 field errors and T2* decay
    dkx     = 0;
    dky     = 0;
    nDwells = gradients.delayDwells;
else
    dkx     = gradients.dkx(t);       % k-space step for this sample, cycles/m
    dky     = gradients.dky(t);
    nDwells = gradients.nDwells(t);   % dwell times in this step (usually 1)
end
duration = nDwells*sim.dt;
gamma    = sim.gamma;
G        = sim.gradientPerStep;

% Phase change from the gradients
step = exp(-1i*gamma*xygrid.x*G*dkx*duration) .* exp(-1i*gamma*xygrid.y*G*dky*duration);

% Phase change from B0 field errors. Skipped when there are none, to save time.
if sim.fieldErrorType ~= "none"
    step = step .* exp(-1i*gamma*fieldError*duration);
end

% T2* decay. sim.t2star may be a scalar or a map the size of the image.
if any(isfinite(sim.t2star(:)))
    step = step .* exp(-duration./sim.t2star);
end

spins.step = step;

% The full phase change should also include the term
%       exp(-1i*gamma*B0*duration)
% for precession in the main field. We drop it because the scanner removes
% it when it demodulates the signal (Lauterbur book).

end
