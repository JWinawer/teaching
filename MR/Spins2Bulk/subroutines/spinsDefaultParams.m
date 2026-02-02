function [params, units] = spinsDefaultParams()

% number of individual spins 
params.nspins = 10000;
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
params.k = 4;  
units.k  ='arbitrary (>=0)';  

% Flip angle in radians. 
params.flipangle = pi/2;            
units.flipangle  = 'radians';  

% Time at which flip is iniated (seconds)
params.fliptime = 0.025;          
units.fliptime  = 's';

end