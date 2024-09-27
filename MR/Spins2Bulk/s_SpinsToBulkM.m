% Set up the figure
fH = figure;

%% Noiseless Larmor precession
[params, units] = spinsDefaultParams();
params.fliptime  = inf;  %   (no flip)      
params.t1 = inf;
params.t2 = inf;

clf;
set(gcf, 'Name', 'Noiseless precession', 'NumberTitle', 'off');
animateSpins(params);

%% Noiseless Larmor precession with 90º flip
params = spinsDefaultParams();
params.t1 = inf;
params.t2 = inf;

clf;
set(gcf, 'Name', 'Noiseless precession with flip', 'NumberTitle', 'off');
animateSpins(params);

%% T2 relaxation, laboratory reference 
params = spinsDefaultParams();
params.t1 = inf;    % seconds 

clf; 
set(gcf, 'Name', 'T2 relaxation, laboratory reference frame', 'NumberTitle', 'off');
animateSpins(params);

%% T2 relaxation, rotating reference frame
params = spinsDefaultParams();

params.t1        = inf;    % seconds 
params.larmor    = 0;

clf;
set(gcf, 'Name', 'T2 relaxation, rotating reference frame', 'NumberTitle', 'off');

animateSpins(params);


%% Slow 90º flip in rotating reference frame
params = spinsDefaultParams();

params.dt        = 0.0001;   % seconds
params.nsteps    = 150; % count
params.fliptime  = 0.001;  % when to initiate flip (seconds)
params.larmor    = 0;

clf
set(gcf, 'Name', 'Slow 90º flip', 'NumberTitle', 'off');

animateSpins(params);

%% Continuous flipping. 

params = spinsDefaultParams();

params.dt        = 0.0001;   % seconds
params.nsteps    = 150; % count
params.fliptime  = 0.001;  % when to initiate flip (seconds)
params.larmor    = 0;
params.flipangle = 50*pi;
params.B1freq    = 250;

clf;
set(gcf, 'Name', 'Continuous flipping', 'NumberTitle', 'off');

animateSpins(params);

%% t1 recovery from 180º flip
params = spinsDefaultParams();

params.dt        = 0.01;% longer dt because we need a longer demo for T1 reovery   
params.nsteps    = 150;     
params.flipangle = pi;

clf;
set(gcf, 'Name', 'T1 relaxation from 180º flip', 'NumberTitle', 'off');

animateSpins(params);

