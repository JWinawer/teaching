function Spins = transverseRelaxation(Spins, params)

[azimuth, elevation, r] = cart2sph(Spins(:,1), Spins(:,2), Spins(:,3));
azimuth = azimuth + randn(size(azimuth))*params.t2stepsize;
[x, y, z] = sph2cart(azimuth, elevation, r);
Spins = [x y z];

end
