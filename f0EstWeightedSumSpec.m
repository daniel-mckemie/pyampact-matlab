function [f0 p t M xf] = f0EstWeightedSumSpec(fileName, noteStart_s, noteEnd_s, f0i, useIf)
%function [f0 p t M xf] = f0EstWeightedSumSpec(fileName, noteStart_s, noteEnd_s, noteMidi, useIf)

% Use f0EstWeightedSum on one note using spectrogram or IF features
%
%   [f0 p t] = f0EstWeightedSumSpec(fileName, noteStart_s, noteEnd_s, noteMidi, useIf)
%
% Inputs:
%   fileName     name of wav file to analyze
%   noteStart_s  start position (in seconds) of note to analyze
%   noteEnd_s    end position (in seconds) of note to analyze
%   noteMidi     midi note number of note to analyze
%   useIf        if true, use instantaneous frequency, else spectrogram frequencies
%
% Outputs:
%   f0  vector of estimated f0s from noteStart_s to noteEnd_s
%   p   vector of corresponding "powers" from f0EstWeightedSum
%   t   time point (in seconds) corresponding to each f0 value

if ~exist('useIf', 'var') || isempty(useIf), useIf = true; end

win_s = 0.064;
nIter = 10;

[s fs] = audioread(fileName);
win = round(win_s * fs); 
hop = round(win / 8);
%hop = round(win / 4);
[F D] = ifgram(s', win, win, hop, fs);

inds = round(noteStart_s * fs / hop) : round(noteEnd_s * fs / hop);

x = abs(D(:,inds)).^(1/6); 
f = (0:win/2)' * fs / win;
if useIf
    xf = F(:,inds);
else
    xf = repmat(f, 1, size(x,2));
end

%f0i = midi2hz(noteMidi);
f0 = f0EstWeightedSum(x, xf, f0i);
for iter = 1:nIter
    f0 = f0EstWeightedSum(x, xf, f0);
end
[~,p,partials] = f0EstWeightedSum(x.^6, xf, f0, 22050);

M=partials{1}; 
for i = 2 : length(partials)
    M=M+partials{i};
end

% Plot it
t = hop / fs * (1 : size(D,2));
% imagesc(t, f, db(D))
% axis xy
% ylim([0 5000]);
% hold on
% plot(t(inds), (1:20)' * f0, 'w--')
% hold off

t = t(inds);
