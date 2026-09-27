function [gx, gy, T] = kspaceSpiral(sim)
% Generate a spiral-out gradient sequence
%
%   [gx, gy, T] = kspaceSpiral(sim)
%
% See McRobbie et al (MRI from picture to proton), 2nd edition, p 370, box.
%
% This is an Archimedean spiral, meaning
%   A = c*theta
% where A is the distance from the centre of k-space, theta is the angle
% (which keeps increasing beyond 2*pi as the spiral wraps around), and c is
% a constant. In kx,ky space:
%
%   kx = 1/(2*pi*FOV) * theta * sin(theta)
%   ky = 1/(2*pi*FOV) * theta * cos(theta)
%
% With c = 1/(2*pi*FOV), successive turns are 1/FOV apart, which is the
% spacing needed to avoid wraparound. The gradients are the derivatives of the
% k-space position with respect to theta (times dtheta per sample):
%
%   Gx = 1/(2*pi*FOV) * dtheta * (sin(theta) + theta*cos(theta))
%   Gy = 1/(2*pi*FOV) * dtheta * (cos(theta) - theta*sin(theta))
%
% Theta increases at a constant rate, so the spiral is traced at a constant
% angular speed. Samples are therefore dense near the centre of k-space and
% sparse at the edge. kspaceRecon corrects for this.
%
% The number of samples is the number of reconstructed pixels, in a single
% shot. Outputs are k-space steps per sample (cycles per metre) and the
% duration of each step (in dwell times). See kspaceMakePulseSequence.

nsamples = sim.freq^2;
c        = 1/(2*pi*sim.FOV);

theta  = linspace(0, sim.freq*pi, nsamples);
dtheta = theta(2) - theta(1);

gx = c*dtheta*(sin(theta) + theta.*cos(theta));
gy = c*dtheta*(cos(theta) - theta.*sin(theta));
T  = ones(1, nsamples);

end
