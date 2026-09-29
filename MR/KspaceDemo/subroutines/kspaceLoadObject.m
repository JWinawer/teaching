function object = kspaceLoadObject(sim)
% Load the object to be scanned, as a grayscale image on the simulation grid.
%
%   object = kspaceLoadObject(sim)
%
% sim.imageFile may be the name of a file in data/, "other" (pick a file),
% or a numeric or logical matrix. The image is resized to
% sim.nObjectPixels x sim.nObjectPixels.
%
% Outputs
%   object.image  - the image, double
%   object.vector - the same, as a row vector, for dot products
%   object.fft    - its 2D Fourier transform
%   object.logFft - log magnitude of the Fourier transform, centered, for
%                   display
%
% See also kspaceDefaultParams

n = sim.nObjectPixels;

if isnumeric(sim.imageFile) || islogical(sim.imageFile)
    img = sim.imageFile;
else
    imageFile = sim.imageFile;
    if strcmpi(imageFile, "other")
        [fileName, folder] = uigetfile("*.*", "Pick any image");
        if isequal(fileName, 0)
            error("kspace:noImage", "No image was selected. Pick an image file, or choose one of the listed images.");
        end
        imageFile = fullfile(folder, fileName);
    elseif ~isfile(imageFile)
        % Look in the demo's data folder
        dataFolder = fullfile(fileparts(fileparts(mfilename("fullpath"))), "data");
        imageFile  = fullfile(dataFolder, imageFile);
    end
    img = imread(imageFile);
end

% Make sure it is grayscale
if ~ismatrix(img)
    img = rgb2gray(img);
end

object.image  = double(imresize(img, [n n]));
object.vector = object.image(:)';
object.fft    = fft2(object.image);
object.logFft = fftshift(log(abs(object.fft) + eps));

end
