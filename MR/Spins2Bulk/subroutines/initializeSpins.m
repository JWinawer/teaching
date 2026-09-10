function [Spins, B_dist, M0] = initializeSpins(params)
% Create a population of spins at thermal equilibrium.
%
%   [Spins, B_dist, M0] = initializeSpins(params)
%
% Spins  is nspins x 3, one unit vector per row
% B_dist is the equilibrium elevation distribution (see boltzmannDistribution)
% M0     is the bulk magnetization vector at equilibrium, i.e. sum of Spins

B_dist = boltzmannDistribution(params.k);

% Elevation is biased toward B0 (Z+); azimuth is uniform.
elevation = B_dist.sample(params.nspins);
azimuth   = rand(size(elevation)) * 2*pi;

% Spherical to cartesian, on the unit sphere
r = ones(size(azimuth));
[x, y, z] = sph2cart(azimuth, elevation, r);
Spins = [x; y; z]';

M0 = sum(Spins);

end
