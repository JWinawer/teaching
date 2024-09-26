% Set up the figure
fH = figure;

%% Thermal equilibrium

params = spinsDefaultParams();
params.k = 3;
params.fliptime  = inf;  %   (no flip)      

animateSpins(params);

%% 90º flip, t2 relaxation, laboratory reference 
% (set t1 to very long)
params = spinsDefaultParams();

params.dt        = 0.002; % seconds
params.nsteps    = 100;   % count
params.t2        = 0.050; % seconds 
params.t1        = 20;    % seconds 

animateSpins(params);

%% same, but in rotating reference fr
params.larmor    = 0;
params.B1carrier = params.larmor;

animateSpins(params);


%% watch a slow 90º flip
params.dt      = 0.0001;   % seconds
params.nsteps  = 150; % count
params.flipangle = pi/2;   % flip angle in radians
params.fliptime  = 0.001;  % when to initiate flip (seconds)

animateSpins(params);

%% continuous flipping
params.k       = 4;
params.dt      = 0.002;   
params.nsteps  = 200; 
params.flipangle = pi*2*50;   % flip angle in radians
params.fliptime  = 0.003;  % when to initiate flip (seconds)
params.t2      = 0.200;
animateSpins(params);

%% t1 recovery
params.t1       = 0.8; % reasonable T1    
params.dt       = 0.01;% longer dt because we need a longer demo for T1 reovery   
params.nsteps   = 100;     
params.fliptime  = 0.055;  
params.flipangle = pi/2;   
params.B1freq    = 1/4/.010; 

animateSpins(params);



%%
