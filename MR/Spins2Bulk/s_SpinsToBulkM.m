% Set up the figure
fH = figure;

%% Noiseless Larmor precession
[params, units] = spinsDefaultParams();
params.fliptime  = inf;  %   (no flip)      
params.t1 = inf;
params.t2 = inf;

animateSpins(params, fH, 'Noiseless precession');

%% Noiseless Larmor precession with 90º flip
params = spinsDefaultParams();
params.t1 = inf;
params.t2 = inf;

animateSpins(params, fH, 'Noiseless precession with flip');

%% T2 relaxation, laboratory reference
params = spinsDefaultParams();

animateSpins(params,fH, 'T2 relaxation, laboratory reference frame');

%% T2 relaxation, rotating reference frame 
params = spinsDefaultParams();
params.larmor = 0;
params.dt = 0.002;

animateSpins(params, fH, 'T2 relaxation, rotating reference frame');

%% T1 and T2 relaxation, rotating reference frame
params = spinsDefaultParams();
params.larmor    = 0;
params.dt        = 0.01;% longer dt because we need a longer demo for T1 reovery   
params.nsteps    = 150;     
params.flipangle = pi/2;

animateSpins(params, fH, 'T1 and T2 relaxation, rotating reference frame');

%% Slow 90º flip in rotating reference frame
params = spinsDefaultParams();

params.dt        = 0.0001;   % seconds
params.nsteps    = 150; % count
params.fliptime  = 0.001;  % when to initiate flip (seconds)
params.larmor    = 0;

animateSpins(params, fH, 'Slow 90º flip');

%% Continuous flipping. 

params = spinsDefaultParams();

params.dt        = 0.0001;   % seconds
params.nsteps    = 150; % count
params.fliptime  = 0.001;  % when to initiate flip (seconds)
params.larmor    = 0;
params.flipangle = 50*pi;
params.B1freq    = 250;

animateSpins(params, fH, 'Continuous flipping');

