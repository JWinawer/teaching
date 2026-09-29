function params = spinsDefaultParams()
% Default parameters for the spin animations.
%
%   params = spinsDefaultParams()
%
% Edit the fields and pass the struct to spinsAnimate (animation) or
% spinsSimulate (no graphics). Times are in ms, frequencies in Hz and angles
% in degrees, the units a scanner console uses. Fields you leave out take
% these defaults, and a field name that is not listed here is an error, so
% that a typo cannot be silently ignored.
%
% Simulation
%   nSpins      - Number of simulated spins.
%   dt          - Time step, ms.
%   nSteps      - Number of time steps. The run lasts nSteps*dt ms.
%
% The field and relaxation
%   k           - Strength of the Boltzmann bias toward B0. No units. 0 means
%                 no field, so spins point in every direction equally. 1 is a
%                 subtle bias, 4 is obvious, and 2-3 is a good compromise. The
%                 real bias is about 1 part in 10^5, far too small to draw, so
%                 k is deliberately exaggerated.
%   larmor      - Larmor (precession) frequency, Hz. Set to 0 to watch in the
%                 rotating reference frame, where the precession is hidden and
%                 everything else is easier to see.
%   t1          - T1 time constant, ms. Inf means no T1 relaxation.
%   t2          - T2 time constant, ms. Inf means no T2 relaxation.
%   b0Spread    - Spread of static B0 offsets across spins, Hz: the half width
%                 of a Lorentzian distribution. This produces T2* decay, as
%                 distinct from T2. 0 means a perfectly uniform field. Use
%                 spinsB0SpreadForT2star to choose the T2* you want instead.
%   fieldOnTime - Time at which B0 switches on, ms. 0 means it is on from the
%                 start. A positive value starts with no field: the spins
%                 point in random directions and sit still until then.
%
% RF pulses. flipAngle, flipTime and flipPhase may each be a vector, to apply
% a train of pulses. Scalars are expanded to match.
%   flipAngle   - Flip angle of each pulse, degrees.
%   flipTime    - Start time of each pulse, ms. Inf means no pulse.
%   flipPhase   - Direction of B1 for each pulse, degrees. 0 is along +x and
%                 90 is along +y. A spin echo is usually [0 90].
%   b1Freq      - Nutation frequency, Hz: how fast a pulse rotates the spins.
%                 The default, 25 Hz, gives a 90 degree flip in 10 ms.
%
% Display
%   frameRate   - Playback speed of the animation, frames per second. This is
%                 not simulation speed: lowering it shows the same physics in
%                 slower motion.
%
% A note on larmor and k. Both are consequences of the same field: the
% precession rate is proportional to B0, and so is the Boltzmann bias. The
% code lets you set them separately because that is convenient for teaching:
%
%   k > 0, larmor > 0   a field, viewed in the laboratory frame
%   k > 0, larmor = 0   the same field, viewed in the rotating frame
%   k = 0, larmor = 0   no field at all
%   k = 0, larmor > 0   unphysical: there is no field to precess about
%
% Example: a spin echo
%   params = spinsDefaultParams();
%   params.flipAngle = [90 180];
%   params.flipTime  = [1 21];     % the echo forms near 42 ms
%   params.flipPhase = [0 90];
%   params.b1Freq    = 500;        % short pulses...
%   params.dt        = 0.1;        % ...so small time steps
%   params.nSteps    = 600;
%   spinsAnimate(params);
%
% See also spinsAnimate, spinsSimulate, spinsB0SpreadForT2star

params.nSpins      = 3000;
params.dt          = 1;     % ms
params.nSteps      = 100;
params.k           = 3;
params.larmor      = 10;    % Hz
params.t1          = 800;   % ms
params.t2          = 50;    % ms
params.b0Spread    = 0;     % Hz
params.fieldOnTime = 0;     % ms
params.flipAngle   = 90;    % degrees
params.flipTime    = 25;    % ms
params.flipPhase   = 0;     % degrees
params.b1Freq      = 25;    % Hz
params.frameRate   = 6;     % frames per second

end
