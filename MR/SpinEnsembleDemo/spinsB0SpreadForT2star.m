function b0Spread = spinsB0SpreadForT2star(t2star, t2)
% Field spread needed to produce a given T2*.
%
%   b0Spread = spinsB0SpreadForT2star(t2star, t2)
%
% Inverts the relation used by spinsDerivedParams,
%
%       1/t2star = 1/t2 + 1/t2prime,   t2prime = 1/(2*pi*b0Spread)
%
% so you can specify the decay you want to see rather than guessing at a
% field spread in Hz. Times are in ms and the result is in Hz.
%
% Example: a 40 ms T2* in tissue whose true T2 is 100 ms
%   params.b0Spread = spinsB0SpreadForT2star(40, 100);
%
% See also spinsDefaultParams

arguments
    t2star (1,1) double {mustBePositive}
    t2 (1,1) double {mustBePositive}
end

if t2star >= t2
    error("spins:impossibleT2star", ...
        "t2star (%g ms) must be shorter than t2 (%g ms). A non-uniform field can only " + ...
        "make the decay faster, never slower.", t2star, t2);
end

msPerS   = 1000;
t2prime  = 1/(1/t2star - 1/t2);        % ms
b0Spread = msPerS/(2*pi*t2prime);      % Hz

end
