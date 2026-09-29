function params = spinsDerivedParams(params)
% Check the parameters and add the values derived from them.
%
%   params = spinsDerivedParams(params)
%
% Fields missing from params take their defaults (spinsDefaultParams). A
% field that is not a known parameter is an error, so a typo or an old
% parameter name cannot be silently ignored. The user-set fields are not
% changed, except that scalar pulse settings are expanded to vectors, so the
% output can be passed back in.
%
% Derived fields (times in ms, angles in radians)
%   t           - time of each step
%   larmorStep  - precession per step
%   fieldOn     - whether B0 is on at each step
%   larmorPhase - precession phase built up by each step
%   t2StepSize  - standard deviation of the random phase step that gives T2
%   t2prime     - decay time constant from the B0 spread alone
%   t2star      - observed transverse decay time constant
%   rfPulse     - at each step, 0 or the index of the pulse that is on
%   flipStep    - rotation per step for each pulse
%   flipPhaseRad - flipPhase in radians
%
% See also spinsDefaultParams

msPerS = 1000;

params = checkFields(params);

% Time of each step
params.t = (1:params.nSteps)*params.dt;

% Precession per time step
params.larmorStep = 2*pi*params.larmor*params.dt/msPerS;

% Whether B0 is on at each time step, and the precession phase the spins
% have built up by each step. The phase only advances while the field is on,
% so an RF pulse given after a late switch-on still turns in step with the
% spins. When the field is on throughout, this is simply n*larmorStep.
params.fieldOn     = params.t >= params.fieldOnTime;
params.larmorPhase = params.larmorStep*cumsum(params.fieldOn);

% Standard deviation, in radians, of the random phase step that produces T2
% decay. A random walk in phase with per-step variance s^2 leaves the
% transverse magnetization at exp(-n*s^2/2) after n steps. Setting that
% equal to exp(-t/T2) = exp(-n*dt/T2) gives s^2 = 2*dt/T2.
params.t2StepSize = sqrt(2*params.dt/params.t2);

% Time constants for the static field spread. A Lorentzian distribution of
% frequency offsets with half width at half maximum b0Spread dephases the
% transverse magnetization exponentially with time constant 1/(2*pi*b0Spread).
if params.b0Spread > 0
    params.t2prime = msPerS/(2*pi*params.b0Spread);
else
    params.t2prime = Inf;
end
params.t2star = 1/(1/params.t2 + 1/params.t2prime);

% RF pulses. Each setting may be a scalar or a vector. Scalars are expanded
% to match the longest of the three.
nPulses = max([numel(params.flipAngle) numel(params.flipTime) numel(params.flipPhase)]);
params.flipAngle = expandToLength(params.flipAngle, nPulses, "flipAngle");
params.flipTime  = expandToLength(params.flipTime, nPulses, "flipTime");
params.flipPhase = expandToLength(params.flipPhase, nPulses, "flipPhase");
params.flipPhaseRad = deg2rad(params.flipPhase);

% rfPulse(n) is 0 when no pulse is on at time step n, and otherwise the index
% of the pulse that is on.
flipAngleRad  = deg2rad(params.flipAngle);
flipDuration  = abs(flipAngleRad)/(2*pi)/params.b1Freq*msPerS;
params.rfPulse  = zeros(1, params.nSteps);
params.flipStep = zeros(1, nPulses);
for ii = 1:nPulses

    % Skip pulses that never start within this run
    if ~isfinite(params.flipTime(ii)) || params.flipTime(ii) > params.t(end)
        continue
    end

    % Work out the pulse on a grid long enough to hold all of it, even if the
    % simulation itself stops partway through. Counting only the steps inside
    % the run would compress the whole flip into the part that fits, turning a
    % pulse that should be cut off partway into a complete one.
    nNeeded    = ceil((params.flipTime(ii) + flipDuration(ii))/params.dt);
    tFull      = (1:max(params.nSteps, nNeeded))*params.dt;
    duringFull = (tFull >= params.flipTime(ii)) & (tFull < params.flipTime(ii) + flipDuration(ii));

    % Rotation applied per time step, chosen so that a complete pulse
    % multiplies out to exactly the flip angle. Without this the flip angle is
    % rounded to whole time steps, and a pulse whose duration is not a
    % multiple of dt over- or undershoots. With b1Freq = 500 Hz and dt = 0.2
    % ms, for instance, a 90 degree pulse covers 2.5 steps and would
    % otherwise round up to 108 degrees.
    if ~any(duringFull)
        warning("spins:pulseTooShort", ...
            "Pulse %d lasts %.3g ms but dt is %.3g ms, so it falls between time steps " + ...
            "and will not be applied. Lower b1Freq or dt.", ii, flipDuration(ii), params.dt);
        continue
    end
    params.flipStep(ii) = flipAngleRad(ii)/sum(duringFull);

    during = duringFull(1:params.nSteps);
    if any(params.rfPulse(during) > 0)
        error("spins:overlappingPulses", ...
            "Pulse %d overlaps an earlier pulse. Space the flipTime entries by at least " + ...
            "the pulse duration, or raise b1Freq.", ii);
    end
    params.rfPulse(during) = ii;

end

end

function params = checkFields(params)
% Fill in missing fields from the defaults, and reject unknown ones

defaults = spinsDefaultParams();
derivedNames = ["t", "larmorStep", "fieldOn", "larmorPhase", "t2StepSize", ...
    "t2prime", "t2star", "rfPulse", "flipStep", "flipPhaseRad"];

% Names used before September 2026, when times were in seconds and angles in
% radians. Listed so the error can say what the new name is.
oldNames = struct("nspins", "nSpins", "nsteps", "nSteps", "flipangle", "flipAngle", ...
    "fliptime", "flipTime", "flipphase", "flipPhase", "B1freq", "b1Freq", "b0spread", "b0Spread");

given   = string(fieldnames(params))';
unknown = setdiff(given, [string(fieldnames(defaults))' derivedNames]);
if ~isempty(unknown)
    hints = strings(size(unknown));
    for ii = 1:numel(unknown)
        if isfield(oldNames, unknown(ii))
            hints(ii) = sprintf(" (now called %s, in new units; see spinsDefaultParams)", ...
                oldNames.(unknown(ii)));
        end
    end
    error("spins:unknownParameter", "Unknown parameter: %s. See spinsDefaultParams for the list.", ...
        join(unknown + hints, ", "));
end

missing = setdiff(string(fieldnames(defaults))', given);
for name = missing
    params.(name) = defaults.(name);
end

% Catch values that look like they were entered in the old units (seconds).
% Real T1 and T2 values are tens of ms or more, and dt is rarely below 0.01 ms.
shortest = struct("t1", 1, "t2", 1, "dt", 0.01);   % ms
for name = string(fieldnames(shortest))'
    value = params.(name);
    if isfinite(value) && value < shortest.(name)
        warning("spins:unitsLookLikeSeconds", ...
            "%s = %g ms is very short. Times are in ms. Did you mean %g?", name, value, value*1000);
    end
end
isNonzero = params.flipAngle ~= 0;
if any(isNonzero) && all(abs(params.flipAngle(isNonzero)) <= 2*pi)
    warning("spins:anglesLookLikeRadians", ...
        "All flip angles are 2*pi or less. Flip angles are in degrees. Did you mean %s?", ...
        mat2str(round(rad2deg(params.flipAngle), 4)));
end

end

function v = expandToLength(v, n, name)
% Expand a scalar to length n, or check that a vector is already that long
v = v(:)';
if isscalar(v)
    v = repmat(v, 1, n);
elseif numel(v) ~= n
    error("spins:pulseLength", "%s must be a scalar or have %d elements.", name, n);
end
end
