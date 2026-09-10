function P = spinsAddDerivedParameters(P)
% Add parameters derived from the user-set fields of P.

% Time vector (seconds)
P.t = (1:P.nsteps) * P.dt;

% Radians of Larmor precession per time step
P.larmorStep = P.larmor * P.dt * 2 * pi;

% Standard deviation, in radians, of the azimuthal random step that produces
% T2 decay. A random walk in phase with per-step variance s^2 leaves the
% transverse magnetization at exp(-n*s^2/2) after n steps. Setting that
% equal to exp(-t/T2) = exp(-n*dt/T2) gives s^2 = 2*dt/T2.
P.t2stepsize = sqrt(2 * P.dt / P.t2);

% Which time steps the RF pulse is on for
flipduration = P.flipangle / (2*pi) / P.B1freq;
P.RFpulse = P.t >= P.fliptime & P.t < P.fliptime + flipduration;

end
