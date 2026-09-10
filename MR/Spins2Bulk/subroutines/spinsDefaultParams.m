function [params, units] = spinsDefaultParams()

% number of individual spins 
params.nspins = 3000;
units.nspins  = 'count';

% time step in seconds
params.dt = 0.001; 
units.dt  = 's';

% number of time points to simulate
params.nsteps = 100;       
units.nsteps = 'count';

% t2 time constant (seconds) 
params.t2 = 0.050;
units.t2  = 's';

% t1 time constant (seconds)
params.t1 = 0.8;
units.t1  = 's';

% Larmor (B0) frequency in cycles per second.  
%   Set to 0 for rotating reference frame. This parameter only affects how
%   fast the spins appear to rotate.
params.larmor = 10;
units.larmor  = 'cycles/s';

% Nutation frequency, cycles/s. This determines fast the RF flips are. 
%   0.25 / .010 means a 90 deg flip (quarter cycle) in 10 ms
params.B1freq = 0.25 /.010;  
units.B1freq  = 'cycles/s';

% Constant for Boltzmann equation. 0 means uniform distribution of spin
%   orientations (ie no magnetifc field). Higher positive numbers represent
%   increasing bias toward the B0 direction, but the units are not
%   meaningful. A value of 1 is a pretty subtle bias. A value of 4 is quite
%   visible. 2 is reasonable. 
params.k = 3;  
units.k  ='arbitrary (>=0)';  

% Flip angle in radians.
%   May be a vector, to apply a train of pulses. For a spin echo, use
%   [pi/2 pi] together with two entries in fliptime.
params.flipangle = pi/2;
units.flipangle  = 'radians';

% Time at which each flip is initiated (seconds)
%   Must be a scalar or the same length as flipangle.
params.fliptime = 0.025;
units.fliptime  = 's';

% Phase of the B1 axis for each flip, in radians.
%   0 puts B1 along +x, pi/2 puts it along +y. A conventional spin echo
%   uses a 90 degree pulse about x followed by a 180 degree pulse about y,
%   which is [0 pi/2]. The echo forms either way; the phase only sets which
%   direction it points.
params.flipphase = 0;
units.flipphase  = 'radians';

% Spread of static B0 offsets across spins, in Hz.
%   This is what produces T2* decay, as distinct from T2. Every spin is
%   given its own fixed frequency offset, drawn from a Lorentzian
%   distribution whose half width at half maximum is b0spread. It
%   represents a magnetic field that is not perfectly uniform across the
%   sample, for instance because deoxygenated blood distorts the field
%   nearby. 0 means a perfectly uniform field, in which case T2* = T2.
%
%   The dephasing this causes is reversible, because each offset is fixed
%   in time: a 180 degree pulse refocuses it into a spin echo. The
%   dephasing caused by t2 is not reversible, because it is a random walk.
%   The difference between the two is the point of the spin echo.
%
%   A Lorentzian spread gives exponential decay with time constant
%       t2prime = 1 / (2*pi*b0spread)
%   and the observed decay combines the two mechanisms as
%       1/t2star = 1/t2 + 1/t2prime
%   spinsAddDerivedParameters computes both of these for you.
params.b0spread = 0;
units.b0spread  = 'Hz';

end