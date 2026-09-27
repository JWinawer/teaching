function im = kspaceGetImage(sim)
% Load the object to be scanned, as a grayscale image on the simulation grid.
%
%   im = kspaceGetImage(sim)
%
% sim.imfile may be a file name, "other" (pick a file), or a numeric matrix.
% The image is resized to sim.imFreq x sim.imFreq pixels.
%
% Outputs
%   im.orig     - the image, double
%   im.vector   - the same, as a row vector, for dot products
%   im.fft      - its 2D Fourier transform
%   im.fftshift - log magnitude of the Fourier transform, centred, for display
%
% JW, Vistasoft, 2009

sz = sim.imFreq;   % pixels along one side of the (square) image

if isnumeric(sim.imfile) || islogical(sim.imfile)
    img = sim.imfile;
else
    imfile = sim.imfile;
    if strcmpi(imfile, "other")
        [fname, pth] = uigetfile("*.*", "Pick any image");
        if isequal(fname, 0)
            error("kspace:noImage", "No image was selected. Pick an image file, or choose one of the listed images.");
        end
        imfile = fullfile(pth, fname);
    end
    img = imread(imfile);
end

% Make sure it is grayscale
if ~ismatrix(img)
    img = rgb2gray(img);
end

im.orig     = double(imresize(img, [sz, sz]));
im.vector   = im.orig(:)';
im.fft      = fft2(im.orig);
im.fftshift = fftshift(log(abs(im.fft) + eps));

end
