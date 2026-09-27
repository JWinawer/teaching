function spins = kspaceGetCurrentBasisFunctions(spins)
% Update the spins to account for the most recent step
%
%   spins = kspaceGetCurrentBasisFunctions(spins)
%
% spins.total is the complex state of every spin. Multiplying it by
% spins.step applies the rotation and decay of the latest step. The real and
% imaginary parts of spins.total are the cosine and sine patterns (basis
% functions) that the image is multiplied by to get the current k-space
% sample.

spins.total = spins.total .* spins.step;

end
