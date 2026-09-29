function kspace = kspaceInitializeData(sim, gradients)
% Set up the k-space data: sample positions, and empty values to fill.
%
%   kspace = kspaceInitializeData(sim, gradients)
%
% The kspace struct has two parts.
%
% kspace.samples holds one entry per sample, in the order they are
% measured. The samples need not lie on a grid (for example in a spiral),
% so they are kept as a list: kx and ky (cycles/m) and the complex signal.
% The key idea is that the k-space position is the running sum (the time
% integral) of the gradient steps.
%
% kspace.grid is the Cartesian grid used for the reconstruction: kx, ky and
% signal, as square matrices with the center of k-space at (1,1), as ifft2
% expects. The signal is filled in by kspaceRecon. For EPI this is simple,
% because the samples already lie on the grid. For a spiral it needs
% interpolation.
%
% See also kspaceMakePulseSequence, kspaceRecon

nSamples = length(gradients.nDwells);

kspace.samples.kx     = cumsum(gradients.dkx.*gradients.nDwells);
kspace.samples.ky     = cumsum(gradients.dky.*gradients.nDwells);
kspace.samples.signal = complex(zeros(1, nSamples));

% Spatial frequencies of the grid, from -kmax to just below +kmax, in steps
% of 1/FOV
n     = sim.nPixels;
freqs = (-n/2:n/2-1)/sim.FOV;
[kxGrid, kyGrid] = meshgrid(freqs, freqs);

kspace.grid.kx     = fftshift(kxGrid);
kspace.grid.ky     = fftshift(kyGrid);
kspace.grid.signal = complex(zeros(n));

end
