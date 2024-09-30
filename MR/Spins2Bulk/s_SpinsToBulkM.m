% Set up the figure
fH = figure;

%% Noiseless Larmor precession
[params, units] = spinsDefaultParams();
params.fliptime  = inf;  %   (no flip)      
params.t1 = inf;
params.t2 = inf;

titlestr = 'Noiseless precession';
SPIN_MOVIE = animateSpins(params, fH, titlestr);
writeMovie(SPIN_MOVIE, fullfile("movies", titlestr));


%% Noiseless Larmor precession with 90º flip
params = spinsDefaultParams();
params.t1 = inf;
params.t2 = inf;

titlestr = 'Noiseless precession with flip';
SPIN_MOVIE = animateSpins(params, fH, titlestr);
writeMovie(SPIN_MOVIE, fullfile("movies", titlestr));


%% T2 relaxation, laboratory reference
params = spinsDefaultParams();

titlestr = 'T2 relaxation in laboratory reference frame';
SPIN_MOVIE = animateSpins(params, fH, titlestr);
writeMovie(SPIN_MOVIE, fullfile("movies", titlestr));

%% T2 relaxation, rotating reference frame 
params = spinsDefaultParams();
params.larmor = 0;
params.dt = 0.002;

titlestr = 'T2 relaxation in rotating reference frame';
SPIN_MOVIE = animateSpins(params, fH, titlestr);
writeMovie(SPIN_MOVIE, fullfile("movies", titlestr));

%% T1 and T2 relaxation, rotating reference frame
params = spinsDefaultParams();
params.larmor    = 0;
params.dt        = 0.01;% longer dt because we need a longer demo for T1 reovery   
params.nsteps    = 150;     
params.flipangle = pi/2;
params.fliptime  = 0.100;
titlestr = 'T1 and T2 relaxation in rotating reference frame';
SPIN_MOVIE = animateSpins(params, fH, titlestr);
writeMovie(SPIN_MOVIE, fullfile("movies", titlestr));

%% Slow 90º flip in rotating reference frame
params = spinsDefaultParams();

params.dt        = 0.0001;   % seconds
params.nsteps    = 150; % count
params.fliptime  = 0.001;  % when to initiate flip (seconds)
params.larmor    = 0;

titlestr = 'Slow 90º flip';
SPIN_MOVIE = animateSpins(params, fH, titlestr);
writeMovie(SPIN_MOVIE, fullfile("movies", titlestr));

%% Continuous flipping. 

params = spinsDefaultParams();

params.dt        = 0.0001;   % seconds
params.nsteps    = 150; % count
params.fliptime  = 0.001;  % when to initiate flip (seconds)
params.larmor    = 0;
params.flipangle = 50*pi;
params.B1freq    = 250;

titlestr = 'Continuous flipping';
SPIN_MOVIE = animateSpins(params, fH, titlestr);
writeMovie(SPIN_MOVIE, fullfile("movies", titlestr));


%% save function

function writeMovie(MOVIE, fname)

v = VideoWriter(fname, "MPEG-4");
v.FrameRate = 12;
open(v);
writeVideo(v, MOVIE);
close(v);

end