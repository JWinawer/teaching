function xygrid = kspacePixelPositions(sim)
% Positions of the simulated object's pixels, in meters.
%
%   xygrid = kspacePixelPositions(sim)
%
% Returns xygrid.x and xygrid.y, each nObjectPixels x nObjectPixels,
% starting from (0, 0) at the upper left. x increases along the columns and
% y down the rows.
%
% The grid has the resolution of the simulated object, not of the
% reconstructed image. The object is finer, so that each reconstructed pixel
% holds several spins. That is needed for dephasing within a pixel, and it
% keeps off-grid (spiral) samples from aliasing.
%
% See also kspaceDefaultParams

n = sim.nObjectPixels;
positions = linspace(0, sim.objectSize - sim.objectPixelSize, n);
[xygrid.x, xygrid.y] = meshgrid(positions, positions);

end
