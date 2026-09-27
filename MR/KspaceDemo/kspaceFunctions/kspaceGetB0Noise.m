function b0noise = kspaceGetB0Noise(sim, xygrid)
% create a map of B0 field inhomogeneities in units of Tesla
%
% b0noise = kspaceGetB0Noise(sim, xygrid);
%
% The B0 inhomogeneity (or noise) is built in this routine.  A realistic
% scale for the B0 non-uniformity is approx 1 part in 10^6 or 10^7 of B0. 
%
% Inputs
%  sim.B0
%  sim.imFreq
%  sim.noiseType  "none", "random offset", "random lowpass", "dc offset",
%                 "x gradient", "y gradient", "local offset", "map"
%  sim.noiseScale  fraction of B0
%  sim.imSize
%  xygrid.{x,y}
%
% Winawer, Vistasoft, 2009

% define some variables to make the equations more readable
B0          = sim.B0;
freq        = sim.imFreq;
noiseType   = sim.noiseType;
noiseScale  = sim.noiseScale;
sz          = sim.imSize;
x           = xygrid.x;
y           = xygrid.y;

% Make the spatial pattern of B0 noise, assuming an amplitude of 1
switch lower(noiseType)
    case 'none'
        b0noise = zeros(freq);
    case {'random' 'random offset'}
        b0noise = randn(freq);
        b0noise  = b0noise / max(b0noise(:));      
    case 'random lowpass'
        % Blobby, low pass noise.
        % Could be parameterized
        b0noise = randn(freq);
        f = fspecial('gaussian',freq,freq/16);
        b0noise  = imfilter(b0noise, f, 'same');
        b0noise  = b0noise / max(b0noise(:));
    case {'dc offset' 'constant' 'uniform'}
        % Mean value is wrong.
        b0noise = ones(freq);
    case 'x gradient'
        % Spatially varying in the x-direction
        b0noise = x / max(x(:));
        b0noise = b0noise - mean(b0noise(:));
    case 'y gradient'
        % Spatially varying in the y-direction
        b0noise = y / max(y(:));
        b0noise = b0noise - mean(b0noise(:));
        
    case {'local' 'local offset'}
        % A local spot
        noiseCenter = [.25 .25]*sz; % todo: make this a variable
        noiseRadius = .01 * sz;
        inds = sqrt((x-noiseCenter(1)).^2 + (y-noiseCenter(2)).^2) < noiseRadius;
        b0noise = zeros(freq);
        b0noise(inds)  = 1;
        f = fspecial('gaussian',freq,freq/16);
        b0noise  = imfilter(b0noise, f, 'same');
        b0noise  = b0noise / max(b0noise(:));
    case 'map'
        % This appears to be a B0 map obtained at the Lucas center
        tmp = load('b0Lucas.mat');
        b0noise = tmp.b0 * 2 * pi/ sim.gamma; % convert from Hz to Tesla
        b0noise = imresize(b0noise, [freq freq]);
        return; % make sure to skip the last step where we scale the noise, 
                % as we have a real quanititative b0 map
    otherwise
        error("kspace:unknownNoiseType", "Unknown noiseType ""%s"". See kspaceDefaultParams for the options.", noiseType);
end

% Scale the amplitude of the B0 noise image as requested
b0noise = b0noise * noiseScale*B0;

end