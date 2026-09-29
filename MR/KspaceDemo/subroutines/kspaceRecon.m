function [kspace, recon] = kspaceRecon(kspace, sim)
% Put the k-space samples onto a Cartesian grid and reconstruct the image.
%
%   [kspace, recon] = kspaceRecon(kspace, sim)
%
% EPI samples already lie on the grid, so each is simply placed in its cell.
%
% Spiral samples do not, so they are interpolated onto the grid
% (kspaceGridKaiserBessel). Before that, each sample is weighted to correct
% for uneven sampling density. The spiral in kspaceSpiral is traced at a
% constant angular speed, so the number of samples per unit area of k-space
% falls off as 1/|k|. Weighting each sample by |k| evens this out.
%
% Outputs
%   kspace - with kspace.grid.signal filled in, center of k-space at (1,1)
%   recon  - the reconstructed image (magnitude), nPixels x nPixels
%
% See also kspaceGridKaiserBessel, kspaceInitializeData

samples = kspace.samples;
n = sim.nPixels;

switch sim.sequenceType
    case "epi"
        % Each sample is a whole number of steps of 1/FOV from the center.
        % Convert its position to a row and column of the centered grid, then
        % move the center to (1,1) to match kspace.grid.
        cols = round(samples.kx*sim.FOV) + n/2 + 1;
        rows = round(samples.ky*sim.FOV) + n/2 + 1;
        gridded = fftshift(accumarray([rows(:) cols(:)], samples.signal(:), [n n]));

    case "spiral"
        kmax    = n/(2*sim.FOV);   % highest spatial frequency, cycles/m
        radius  = hypot(samples.kx, samples.ky);
        weights = radius;         % density compensation (see help)

        % The gridding code takes positions as complex numbers: real part
        % along the grid rows (ky) and imaginary part along the columns (kx)
        kTrajectory = (samples.ky + 1i*samples.kx)/(2*kmax);
        gridded     = fftshift(kspaceGridKaiserBessel(samples.signal, kTrajectory, weights, n));

        % Gridding leaves an arbitrary overall scale. Rescale so that the
        % center of the grid matches the measured sample nearest the center,
        % which puts spiral and EPI k-space and images on the same scale.
        [~, nearest] = min(radius);
        if abs(gridded(1,1)) > 0
            gridded = gridded*abs(samples.signal(nearest))/abs(gridded(1,1));
        end

    otherwise
        error("kspace:unknownSequence", ...
            "Unknown sequence type ""%s"". Use ""epi"" or ""spiral"".", sim.sequenceType);
end

kspace.grid.signal = gridded;
recon = abs(ifft2(gridded));

end
