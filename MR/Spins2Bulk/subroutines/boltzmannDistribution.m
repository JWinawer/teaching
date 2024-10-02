function B_dist = boltzmannDistribution(k)
% Generate a probabilitiy distritbuion of the elevation of spin axes in a
% magnetic field, assuming the magnetic field is in the Z+ direction
% (elevation pi/2). 
%
% The energy is assumed to increase with the deviation from Z+. The input k
% is a scalar subsuming three constants: the slope of energy vs elevation
% (or really, energy vs the negative projection onto Z), the boltzmann
% constant K, and the temperature. The latter two are used in converting
% energy to probability. There is no attempt at capturing meaningul
% physical values, as we would need to simulate trillions of spins for
% that. Instead, we just choose a value of k that creates a nice amount of
% visible bias in the spin distribution as a function of elevation. Values
% of 2 to 4 seem to work well.

% x the elevation of the spin axis
x = linspace(-pi/2,pi/2, 10000);
dx = x(2)-x(1);

% Probability of spin axis elevation:
%   Boltzmann distribution
%       p ~ exp(-E/(kT));
%   The energy, E, is minimal at 90º elevation, ie the B0+ direction, and
%   declines with a cosine dependence for other elevations. But the
%   circumference of a sphere at a particular elevation is proportional to
%   abs(cosine) of that elevation, and we need to scale the probability by
%   this factor to achieve uniform distribution per unit area when k is 0. 

Energy      = @(X) -cos(X-pi/2);
Probability = @(X) exp(-k*Energy(X));
P           = @(X) Probability(X).*abs(cos(X));
PDF         = @(X) P(X) ./ sum(P(X)) / dx;

% Convert to a probability density function
fx = PDF(x);   

% convert to a cumulative probability distribution 
Fx = cumsum(fx); Fx = Fx/Fx(end);
Fx(1) = 0;  Fx(end)=1; % ensure the CDF starts at 0 and ends at 1
B_dist = makedist('PiecewiseLinear', 'x', x, 'Fx', Fx);

end