function kspace = kspaceRecon(kspace, sim)
% Put the k-space samples onto a Cartesian grid, ready for an inverse FFT.
%
%   kspace = kspaceRecon(kspace, sim)
%
% EPI samples already lie on the grid, so they are simply placed there.
%
% Spiral samples do not, so they are interpolated onto the grid with a
% Kaiser-Bessel kernel ("gridding"; Jackson et al., 1991, IEEE Trans Med
% Imaging 10:473-478). Before gridding, each sample is weighted to correct
% for uneven sampling density. The spiral in kspaceSpiral is traced at a
% constant angular speed, so the number of samples per unit area of k-space
% falls off as 1/|k|. Weighting each sample by |k| evens this out.
%
% Outputs are kspace.grid.real and kspace.grid.imag, with the centre of
% k-space at (1,1), as ifft2 expects.

v = kspace.vector;

switch lower(sim.sequenceType)
    case "epi"
        % Each sample is at a whole number of steps of 1/FOV from the centre.
        % Convert its position to a row and column of the centred grid, then
        % move the centre to (1,1) to match kspace.grid.
        n    = sim.freq;
        cols = round(v.x*sim.FOV) + n/2 + 1;
        rows = round(v.y*sim.FOV) + n/2 + 1;
        kr   = fftshift(accumarray([rows(:) cols(:)], v.real(:), [n n]));
        ki   = fftshift(accumarray([rows(:) cols(:)], v.imag(:), [n n]));

    case "spiral"
        data   = 1i*v.real + v.imag;           % k-space data
        kmax   = sim.freq/sim.FOV*0.5;          % highest spatial frequency, cycles/m
        kTraj  = (-1i*v.x + v.y)/(kmax*2);      % trajectory, scaled to [-0.5 0.5]
        [~, r] = cart2pol(v.x, v.y);
        w      = r;                            % density compensation (see help)

        n              = sim.freq;             % pixels per side of the reconstructed image
        oversample     = 2;                    % grid oversampling
        kbwidth        = 2.5;                  % full width of the Kaiser-Bessel kernel
        kbbeta         = (oversample-0.5)*pi*kbwidth;  % kernel shape parameter
        trimming       = 'y';
        apodize        = 'y';
        postcompensate = 'n';                  % 'y' would undo the density weighting

        k  = grid_kb(data', kTraj', w', n, oversample, kbwidth, kbbeta, trimming, apodize, postcompensate);
        k  = fftshift(k);

        % Gridding leaves an arbitrary overall scale. Rescale so that the
        % centre of the grid matches the measured sample nearest the centre,
        % which puts spiral and EPI k-space and images on the same scale.
        [~, nearest] = min(r);
        measured = complex(v.real(nearest), v.imag(nearest));
        if abs(k(1,1)) > 0
            k = k*abs(measured)/abs(k(1,1));
        end
        kr = real(k);
        ki = imag(k);

    otherwise
        error("kspace:unknownSequence", ...
            "Unknown sequence type ""%s"". Use ""epi"" or ""spiral"".", sim.sequenceType);
end

kspace.grid.real = kr;
kspace.grid.imag = ki;

end
