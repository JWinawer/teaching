function Spins = relaxationLongitudinal(Spins, params, B)

[azimuth, elevation, r] = cart2sph(Spins(:,1), Spins(:,2), Spins(:,3));

dx   =  sqrt(params.dt) / params.t1 / sqrt(params.k) / sqrt(2);

p_up   = B.pdf(elevation+dx);
p_down = B.pdf(elevation-dx);

p_up = p_up./(p_up + p_down);

up = p_up > rand(size(elevation)); 

deltaE = dx*(up*2-1)*2;

elevation = elevation + deltaE;

[x, y, z] = sph2cart(azimuth, elevation, r);
Spins = [x y z];

end