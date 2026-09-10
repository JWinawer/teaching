function B = boltzmannDistribution(k)
% Distribution of spin-axis elevations in a magnetic field along Z+.
%
%   B = boltzmannDistribution(k)
%
% Returns a struct with three fields:
%   B.pdf(x)    probability density of elevation x (radians, in [-pi/2 pi/2])
%   B.sample(n) draw n elevations from that density (row vector)
%   B.Mz        equilibrium magnetization per spin, i.e. mean of sin(elevation)
%
% The energy of a spin is lowest when it points along Z+ (elevation pi/2)
% and increases with the deviation from Z+, so the Boltzmann distribution is
%
%       p ~ exp(-E/(kT)),   E = -sin(elevation)
%
% The input k subsumes three constants: the slope of energy vs. the
% projection onto Z, the Boltzmann constant, and the temperature. No attempt
% is made to capture physically meaningful values -- the real bias is about
% 1 part in 10^5, which would require simulating trillions of spins to see.
% Instead k is chosen to make the bias visible. A value of 1 is a subtle
% bias, 4 is quite visible, and 2-3 is a good compromise. k = 0 means no
% field, i.e. a uniform distribution of orientations.
%
% Note that the circumference of a sphere at a given elevation is
% proportional to abs(cos(elevation)), so the density per unit elevation
% must be scaled by that factor for the spins to be spread uniformly over
% the sphere's surface when k is 0.
%
% Everything below is in closed form, so this needs no toolboxes and the
% sampling is exact rather than interpolated from a numeric CDF.

validateattributes(k, {'numeric'}, {'scalar','real','nonnegative','finite'});

% Normalizing constant: integral of exp(k*sin x)*cos x over [-pi/2 pi/2].
if k == 0
    Z = 2;
else
    Z = 2*sinh(k)/k;
end

B.pdf = @(x) exp(k*sin(x)) .* abs(cos(x)) .* (abs(x) <= pi/2) / Z;

% Sampling. Substituting u = sin(elevation) turns the density into
% p(u) ~ exp(k*u) on [-1 1], whose cumulative distribution inverts
% analytically. The form below stays accurate for large k.
if k == 0
    B.sample = @(n) asin(2*rand(1,n) - 1);
else
    B.sample = @(n) asin(min(max( ...
        1 + log(exp(-2*k) + rand(1,n)*(1 - exp(-2*k)))/k, -1), 1));
end

% Equilibrium magnetization per spin is the Langevin function of k.
if k == 0
    B.Mz = 0;
else
    B.Mz = coth(k) - 1/k;
end

end
