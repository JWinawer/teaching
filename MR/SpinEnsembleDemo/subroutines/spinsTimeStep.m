function Spins = spinsTimeStep(Spins, params, stepnum, B_dist, offsetStep)
% Advance the spin population by one time step.
%
%   Spins = spinsTimeStep(Spins, params, stepnum, B_dist, offsetStep)
%
% The four things that happen to a spin in one step, in order:
%   1. it precesses about B0, at the Larmor frequency plus its own offset
%   2. it is rotated by B1, if an RF pulse is on at this step
%   3. its phase takes a random step, which is T2
%   4. its elevation takes a small biased step, which is T1
%
% Steps 1, 3 and 4 all need the field. Before B0 is switched on (see
% params.fieldOnTime) there is nothing to precess about, and the spins are
% already at the no-field equilibrium, spread evenly over the sphere, so
% only step 2 can move them.
%
% Both animateSpins and simulateSpins call this, so the physics lives in one
% place and the two cannot drift apart.

fieldIsOn = params.fieldOn(stepnum);

if fieldIsOn
    Spins = rotateB0(Spins, params, offsetStep);
end

Spins = rotateB1(Spins, params, stepnum);

if fieldIsOn
    Spins = relaxationTransverse(Spins, params);
    Spins = relaxationLongitudinal(Spins, params, B_dist);
end

end
