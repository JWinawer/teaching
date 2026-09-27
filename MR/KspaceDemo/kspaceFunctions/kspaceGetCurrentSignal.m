function kspace = kspaceGetCurrentSignal(kspace, t, im, spins, sim)
% Measure one k-space sample: the total signal from all the spins.
%
%   kspace = kspaceGetCurrentSignal(kspace, t, im, spins, sim)
%
% Description
%   The signal is the sum over the image of (image value) x (spin state).
%   The spin state is exp(-i*phase), so its real part is the cosine pattern
%   and its imaginary part is minus the sine pattern. Multiplying the image
%   by each pattern and summing gives the real and imaginary parts of one
%   k-space sample. Those are the two channels the scanner records.
%
%   In the early days of MRI there were two separate receiver channels for
%   the real and imaginary parts. Now the signal is digitized at a very high
%   rate and both parts are computed from one channel.
%
% Winawer, Vistasoft, 2009

pixelArea = sim.imRes^2;
imv       = im.vector;

kspace.vector.real(t) = imv * reshape(real(spins.total), [], 1) * pixelArea;
kspace.vector.imag(t) = imv * reshape(imag(spins.total), [], 1) * pixelArea;

end
