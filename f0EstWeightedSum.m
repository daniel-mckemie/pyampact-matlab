function [f0, pow, strips] = f0EstWeightedSum(x, f, f0i, fMax, fThresh)

% Estimate f0 for a matrix (or vector) of amplitudes and frequencies
%
%  f0 = f0EstWeightedSum(x, f0i, fMax, fThresh)
%
% Inputs:
%   x    FxT matrix of complex spectrogram values
%   f    FxT matrix of frequencies of each of those spectrogram values
%   f0i  1xT vector of initial estimates of f0 for each time
%   fMax     maximum frequency to consider in weighted sum
%   fThresh  maximum distance in Hz from each harmonic to consider

if ~exist('fMax', 'var') || isempty(fMax), fMax = 5000; end
if ~exist('fThresh', 'var') || isempty(fThresh), fThresh = 2*median(diff(f(:,1))); end

x2 = magSq(x);
wNum = zeros(size(x2));
wDen = zeros(size(x2));

maxI = max(fMax ./ f0i);
for i = 1:maxI
    strip = (abs(bsxfun(@minus, f, f0i*i)) < fThresh) .* x2;    
    strips{i}=strip;
    wNum = wNum + 1/i * strip;
    wDen = wDen + strip;
end

wNum = wNum .* (f < fMax);
wDen = wDen .* (f < fMax);

f0 = sum(wNum .* f, 1) ./ sum(wDen, 1);
pow = sum(wDen, 1);

%plotYs(wNum, wDen)
