function spins = kspaceComputeOnePoint(sim, gradients, xygrid, b0noise, spins, t)
% Calculate the change in each spin over one step of the sequence.
%
%   spins = kspaceComputeOnePoint(sim, gradients, xygrid, b0noise, spins, t)
%
% Description
%   Each simulated pixel is treated as one spin with a complex value. Over
%   each step, the spin is multiplied by a small complex factor, spins.step,
%   which has two parts:
%     - a rotation (phase change) from the gradients and from any B0 field
%       error at that location
%     - a shrinkage from T2* decay, if sim.t2star is finite
%   kspaceGetCurrentBasisFunctions then multiplies the running total by it.
%
% Inputs
%   sim       - SI parameters (kspaceDerivedParams)
%   gradients - from kspaceMakePulseSequence
%   xygrid    - pixel positions, metres (kspaceGrid)
%   b0noise   - B0 field error at each pixel, tesla (kspaceGetB0Noise)
%   spins     - spin state. If spins.precompute exists, the step is looked
%               up instead of computed.
%   t         - sample number. t = 0 means the wait between excitation and
%               the start of the readout, when the gradients are off.
%
% Outputs
%   spins     - with spins.step set for this step
%
% Winawer, Vistasoft, 2009

% If the step was precomputed, look it up
if isfield(spins, "precompute")
    spins.step = spins.precompute(:,:,spins.precomputeIndex(t));
    return
end

gamma = sim.gamma;   % gyromagnetic ratio of hydrogen, rad/s/T
dt    = sim.dt;      % dwell time, s
gx    = sim.gx;      % gradient per unit k-space step, T/m
gy    = sim.gy;

x = xygrid.x;        % pixel positions in metres, starting from 0,0
y = xygrid.y;        % (upper left)

if t == 0
    % The wait before the readout: gradients off, so the only effects are
    % dephasing from B0 field errors and T2* decay
    GX = 0;
    GY = 0;
    T  = gradients.delay;
else
    GX = gradients.x(t);   % k-space step for this sample, cycles/m
    GY = gradients.y(t);
    T  = gradients.T(t);   % number of dwell times in this step (usually 1)
end
duration = T*dt;

% Phase change from the gradients
step = exp(-1i*gamma*x*gx*GX*duration) .* exp(-1i*gamma*y*gy*GY*duration);

% Phase change from B0 field errors. Skipped when there are none, to save time.
if sim.noiseType ~= "none"
    step = step .* exp(-1i*gamma*b0noise*duration);
end

% T2* decay. sim.t2star may be a scalar or a map the size of the image.
if any(isfinite(sim.t2star(:)))
    step = step .* exp(-duration./sim.t2star);
end

spins.step = step;

% The total spin change should also include the term
%       exp(-1i*gamma*B0*duration)
% for precession in the main field. We drop it because the scanner removes
% it when it demodulates the signal (Lauterbur book).

end
