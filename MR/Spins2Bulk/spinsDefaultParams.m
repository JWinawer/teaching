function params = spinsDefaultParams()

% number of individual spins 
params.nspins = 10000;

% time step in seconds
params.dt = 0.001; 

% number of time points to simulate
params.nsteps = 100;       

% t2 time constant (seconds) 
params.t2 = 0.050;

% t1 time constant (seconds)
params.t1 = 0.8;

% Larmor (B0) frequency in cycles per second.  
%   Set to 0 for rotating reference frame. This parameter only affects how
%   fast the spins appear to rotate.
params.larmor    = 10;

% B1 carrier frequency in cycles/s. This should match the Larmor frequency.
%   We allow it to differ in case we want to see how B1 fields become
%   ineffective when off resonance.
params.B1carrier = params.larmor;   

% B1 rotation frequency, cycles/pe. This determines fast the RF flips are. 
%   0.25 / .010 means a 90 deg flip (quarter cycle) in 10 ms
params.B1freq    = 0.25 /.010;  

% Constant for Boltzmann equation. 0 means uniform distribution of spin
%   orientations (ie no magnetifc field). Higher positive numbers represent
%   increasing bias toward the B0 direction, but the units are not
%   meaningful. A value of 1 is a pretty subtle bias. A value of 4 is quite
%   visible. 2 is reasonable. 
params.k         = 2;  

% Flip angle in radians. 
params.flipangle = pi/2;            

% Time at which flip is iniated (seconds)
params.fliptime  = 0.025;          

end