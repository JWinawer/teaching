function gridded = kspaceGridKaiserBessel(data, kTrajectory, weights, n)
% Interpolate non-Cartesian k-space samples onto a Cartesian grid.
%
%   gridded = kspaceGridKaiserBessel(data, kTrajectory, weights, n)
%
% This is "gridding" (Jackson et al., 1991, IEEE Trans Med Imaging
% 10:473-478). Each sample is spread onto nearby grid points with a
% Kaiser-Bessel kernel, on a grid twice as fine as the final one. The blur
% that the kernel adds to the image is then divided out ("deapodization"),
% and the extra field of view from the finer grid is trimmed off.
%
% Inputs
%   data        - complex k-space samples
%   kTrajectory - sample positions as complex numbers, real part along the
%                 grid rows and imaginary part along the columns, scaled to
%                 [-0.5 0.5]
%   weights     - density compensation weight for each sample
%   n           - size of the output grid, n x n
%
% Output
%   gridded     - n x n gridded k-space
%
% Adapted from gridding code that the original comments credit to Atsushi
% (full attribution unknown). Simplified in 2026 to the options the demo
% uses, with the same arithmetic.
%
% See also kspaceRecon

oversample   = 2;                                % grid oversampling
kernelWidth  = 2.5;                              % full width of the kernel, in grid points
kernelBeta   = (oversample - 0.5)*pi*kernelWidth; % kernel shape parameter
nFine        = oversample*n;
halfReach    = floor(kernelWidth*oversample/2);

data        = data(:);
kTrajectory = kTrajectory(:);
weightedData = data.*weights(:);

% Sample positions in units of fine-grid points
rowPosition = (nFine/2 + 1) + nFine*real(kTrajectory);
colPosition = (nFine/2 + 1) + nFine*imag(kTrajectory);

% Spread each sample onto the grid points around it
fine = zeros(nFine);
for rowOffset = -halfReach:halfReach
    for colOffset = -halfReach:halfReach

        % Nearest grid points
        rowIndex = round(rowPosition + rowOffset);
        colIndex = round(colPosition + colOffset);

        % Separable kernel
        rowKernel = kaiserBesselKernel((rowPosition - rowIndex)/oversample, kernelWidth, kernelBeta);
        colKernel = kaiserBesselKernel((colPosition - colIndex)/oversample, kernelWidth, kernelBeta);

        % Samples that fall outside the grid go on its edge
        rowIndex = min(max(rowIndex, 1), nFine);
        colIndex = min(max(colIndex, 1), nFine);

        fine = fine + sparse(rowIndex, colIndex, weightedData.*rowKernel.*colKernel, nFine, nFine);
    end
end

% Zero the edges, where the out-of-range samples were put
fine(:, [1 nFine]) = 0;
fine([1 nFine], :) = 0;

% Deapodization: divide the image by the Fourier transform of the kernel
kernelOffsets = -halfReach:halfReach;
kernel1D = kaiserBesselKernel(kernelOffsets/oversample, kernelWidth, kernelBeta);
apodization = zeros(nFine);
apodization(nFine/2 + 1 + kernelOffsets, nFine/2 + 1 + kernelOffsets) = max(kernel1D', 0)*max(kernel1D, 0);
apodization = fftshift(fft2(fftshift(apodization)));
apodization = real(apodization)/apodization(nFine/2 + 1, nFine/2 + 1);
apodization(apodization < 1e-5) = 1;   % avoid dividing by (nearly) zero

fine = fftshift(fft2(fftshift(fine)));
fine = fine./apodization;
fine = fftshift(ifft2(fftshift(fine)));

% Trim the extra field of view added by the finer grid
fineImage = ifft2(fine);
gridded   = fft2(fineImage(1:n, 1:n));

end

function y = kaiserBesselKernel(k, width, beta)
% Kaiser-Bessel kernel of the given full width, zero outside it
y = zeros(size(k));
inside = abs(k) <= width/2;
y(inside) = real((1/besseli(0, beta))*besseli(0, beta*sqrt(1 - (2*k(inside)/width).^2)));
end
