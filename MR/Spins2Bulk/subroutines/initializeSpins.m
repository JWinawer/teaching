function [Spins, B_dist, M0] = initializeSpins(params)

B_dist = boltzmannDistribution(params.k);

% sample the CDF to determine spin elevations
elevation = random(B_dist, 1, params.nspins);

% now randomly generate azimuth
azimuth = rand(size(elevation))*2*pi;

% spherical to cartesian 
r = ones(size(azimuth));
[x,y,z] = sph2cart(azimuth,elevation,r);
Spins = [x; y; z]';

M0 = sum(Spins);

end