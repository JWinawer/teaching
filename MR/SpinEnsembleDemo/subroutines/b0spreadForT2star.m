function b0spread = b0spreadForT2star(t2star, t2)
% Field spread needed to produce a given T2*.
%
%   b0spread = b0spreadForT2star(t2star, t2)
%
% Inverts the relation used by spinsAddDerivedParameters,
%
%       1/t2star = 1/t2 + 1/t2prime,   t2prime = 1/(2*pi*b0spread)
%
% so you can specify the decay you want to see rather than guessing at a
% field spread in Hz. All times in seconds, result in Hz.
%
% Example, a 40 ms T2* in tissue whose true T2 is 100 ms:
%   params.b0spread = b0spreadForT2star(0.040, 0.100);

if t2star >= t2
    error('b0spreadForT2star:impossible', ...
        ['t2star (%g s) must be shorter than t2 (%g s). A non-uniform ' ...
         'field can only make the decay faster, never slower.'], t2star, t2);
end

t2prime  = 1 / (1/t2star - 1/t2);
b0spread = 1 / (2*pi*t2prime);

end
