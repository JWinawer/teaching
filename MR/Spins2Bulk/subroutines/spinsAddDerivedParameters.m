function P = spinsAddDerivedParameters(P)
P.t            = (1:P.nsteps) * P.dt; % seconds
P.larmorStep   = P.larmor * P.dt * 2 * pi; % radians
P.t2stepsize   = sqrt(1.9/P.t2*P.dt); % sd of radians per step for random walk causing t2 decay
flipduration   = P.flipangle / (2*pi) / P.B1freq;
P.RFpulse      = P.t >= P.fliptime & P.t < P.fliptime + flipduration;

end