function Spins = relaxationLongitudinal(Spins, params, B)
% T1 relaxation: a biased random walk of each spin's elevation.
%
%   Spins = relaxationLongitudinal(Spins, params, B)
%
% Each spin takes a small step in elevation, up or down, with the two
% directions weighted by the equilibrium probability of landing there. This
% is the picture Williamson (2019) argues for: longitudinal relaxation is a
% large number of small reorientations, not a few 180-degree spin flips. The
% walk samples the Boltzmann distribution B, so the population relaxes to
% thermal equilibrium no matter where it starts.
%
% Step size. The walk above is a Langevin sampler whose diffusion
% coefficient is D = 2*dx^2/dt, and the resulting Mz relaxes exponentially
% at a rate lambda(k)*D. So to make the observed time constant equal
% params.t1 we need
%
%       dx = sqrt( dt / (2*lambda(k)*t1) )
%
% As k goes to 0 this is ordinary rotational diffusion on a sphere, for
% which lambda is exactly l*(l+1) = 2 for the l = 1 mode that Mz belongs to.
% Raising k to make the equilibrium bias visible also steepens the energy
% landscape, which genuinely speeds relaxation up, so lambda has to grow
% with k. The polynomial below was fit to simulations over k = 1 to 5 and
% recovers the exact value of 2 at k = 0.
%
% One caveat worth knowing, and worth telling students. Real longitudinal
% relaxation is single exponential because the real polarization is tiny,
% about 1 part in 10^5, which is the k -> 0 limit. There the calibration
% here is exact. Once k is raised enough to see the bias on screen, the
% recovery is no longer exactly single exponential, so the observed time
% constant depends somewhat on how the magnetization was prepared. The fit
% below is calibrated for the preparation these demos use, a 90 degree RF
% pulse applied to the equilibrium distribution, and over k = 1 to 5 that
% case comes out within 2% of the nominal t1. Other preparations differ a
% little: at the default k = 3 an inversion recovery reads about 10% slow.
% That spread is a property of the exaggeration, not a defect in the code,
% and it is the same kind of cartooning that lets us draw a visible excess
% of spins pointing along B0 in the first place.

lambda = 2 + 0.2258*params.k^2 - 0.0109*params.k^3;

dx = sqrt(params.dt / (2 * lambda * params.t1));

% t1 = inf means no longitudinal relaxation, so there is nothing to do
if dx == 0, return; end

[azimuth, elevation, r] = cart2sph(Spins(:,1), Spins(:,2), Spins(:,3));

% Probability of stepping up vs. down, from the equilibrium density at the
% two candidate elevations. Outside the sphere the density is 0, so a spin
% at the pole is always turned back.
p_up   = B.pdf(elevation + dx);
p_down = B.pdf(elevation - dx);
p_up   = p_up ./ max(p_up + p_down, eps);

up = p_up > rand(size(elevation));

elevation = elevation + 2*dx*(2*up - 1);

% Elevations that overshoot a pole are folded back by sph2cart, which also
% flips the azimuth by pi -- exactly what passing over the pole should do.
[x, y, z] = sph2cart(azimuth, elevation, r);
Spins = [x y z];

end
