function P = spinsAddDerivedParameters(P)
% Add parameters derived from the user-set fields of P.
%
% See also SPINSDEFAULTPARAMS

% Backward compatibility: fields added after the original release
if ~isfield(P, 'b0spread'),  P.b0spread  = 0; end
if ~isfield(P, 'flipphase'), P.flipphase = 0; end

% Time vector (seconds)
P.t = (1:P.nsteps) * P.dt;

% Radians of Larmor precession per time step
P.larmorStep = P.larmor * P.dt * 2 * pi;

% Standard deviation, in radians, of the azimuthal random step that produces
% T2 decay. A random walk in phase with per-step variance s^2 leaves the
% transverse magnetization at exp(-n*s^2/2) after n steps. Setting that
% equal to exp(-t/T2) = exp(-n*dt/T2) gives s^2 = 2*dt/T2.
P.t2stepsize = sqrt(2 * P.dt / P.t2);

% Time constants for the static field spread. A Lorentzian distribution of
% frequency offsets with half width at half maximum b0spread dephases the
% transverse magnetization exponentially with time constant 1/(2*pi*b0spread).
if P.b0spread > 0
    P.t2prime = 1 / (2*pi*P.b0spread);
else
    P.t2prime = inf;
end
P.t2star = 1 / (1/P.t2 + 1/P.t2prime);

% RF pulses. flipangle, fliptime and flipphase may each be a scalar or a
% vector, so that a train of pulses can be applied. Scalars are expanded to
% match the longest of the three.
npulses = max([numel(P.flipangle) numel(P.fliptime) numel(P.flipphase)]);
P.flipangle = expandToLength(P.flipangle, npulses, 'flipangle');
P.fliptime  = expandToLength(P.fliptime,  npulses, 'fliptime');
P.flipphase = expandToLength(P.flipphase, npulses, 'flipphase');

% RFpulse(n) is 0 when no pulse is on at time step n, and otherwise the
% index of the pulse that is on.
flipduration = abs(P.flipangle) / (2*pi) / P.B1freq;
P.RFpulse  = zeros(1, P.nsteps);
P.flipstep = zeros(1, npulses);
for ii = 1:npulses

    % Skip pulses that never start within this run
    if ~isfinite(P.fliptime(ii)) || P.fliptime(ii) > P.t(end), continue; end

    % Work out the pulse on a grid long enough to hold all of it, even if
    % the simulation itself stops partway through. Counting only the steps
    % inside the run would compress the whole flip into the part that fits,
    % turning a pulse that should be cut off partway into a complete one.
    nNeeded    = ceil((P.fliptime(ii) + flipduration(ii)) / P.dt);
    tFull      = (1:max(P.nsteps, nNeeded)) * P.dt;
    duringFull = tFull >= P.fliptime(ii) & tFull < P.fliptime(ii) + flipduration(ii);

    % Rotation applied per time step, chosen so that a complete pulse
    % multiplies out to exactly flipangle. Without this the flip angle is
    % quantized to whole time steps, and a pulse whose duration is not a
    % multiple of dt over- or undershoots. With B1freq = 500 and dt = 2e-4,
    % for instance, a nominal 90 degree pulse covers 2.5 steps and would
    % otherwise round up to 108 degrees.
    if ~any(duringFull)
        warning('spinsAddDerivedParameters:pulseTooShort', ...
            ['Pulse %d lasts %.3g s but dt is %.3g s, so it falls between ' ...
             'time steps and will not be applied. Lower B1freq or dt.'], ...
            ii, flipduration(ii), P.dt);
        continue
    end
    P.flipstep(ii) = P.flipangle(ii) / sum(duringFull);

    during = duringFull(1:P.nsteps);
    if any(P.RFpulse(during) > 0)
        error('spinsAddDerivedParameters:overlappingPulses', ...
            ['Pulse %d overlaps an earlier pulse. Space the fliptime ' ...
             'entries by at least the pulse duration, or raise B1freq.'], ii);
    end
    P.RFpulse(during) = ii;

end

end

function v = expandToLength(v, n, name)
% Expand a scalar to length n, or check that a vector is already that long.
v = v(:)';
if isscalar(v)
    v = repmat(v, 1, n);
elseif numel(v) ~= n
    error('spinsAddDerivedParameters:pulseLength', ...
        '%s must be a scalar or have %d elements.', name, n);
end
end
