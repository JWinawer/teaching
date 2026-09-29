function kspace = kspaceMeasureSample(kspace, t, object, spins, sim)
% Measure one k-space sample: the total signal from all the spins.
%
%   kspace = kspaceMeasureSample(kspace, t, object, spins, sim)
%
% The signal is the sum over the object of (image value) x (spin state).
% The spin state is exp(-i*phase), so its real part is the cosine pattern
% and its imaginary part is minus the sine pattern. Multiplying the image by
% each pattern and summing gives the real and imaginary parts of one k-space
% sample. Those are the two channels the scanner records.
%
% In the early days of MRI there were two separate receiver channels for the
% real and imaginary parts. Now the signal is digitized at a very high rate
% and both parts are computed from one channel.
%
% See also kspaceSimulate, kspaceStepFactor

pixelArea = sim.objectPixelSize^2;
kspace.samples.signal(t) = (object.vector*spins.state(:))*pixelArea;

end
