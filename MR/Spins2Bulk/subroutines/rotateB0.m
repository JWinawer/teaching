function Spins = rotateB0(Spins, params)

[azimuth, elevation, r] = cart2sph(Spins(:,1), Spins(:,2), Spins(:,3));
azimuth = azimuth + params.larmorStep;
[x, y, z] = sph2cart(azimuth, elevation, r);
Spins = [x y z];

end