%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% polyphonicDemo.m
%
% Description: 
%   Score-guided estimation frame-wise f0 and power estimations
%   and percetual note-wise parameters from polyphonic audio
%
% Automatic Music Performance Analysis and Analysis Toolkit (AMPACT) 
% http://www.ampact.org
% (c) copyright 2018 Johanna Devaney (j@devaney.ca), all rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% audio file
audiofile = 'polyExample.wav';
[sig,sr]=audioread(audiofile);

% midifile
midifile = 'polyExample.mid';

% HMM parameters
meansCovarsMat='polySingingMeansCovars.mat';

% voice type for each polyphonic line
voiceType = [2 1 1 1]; 

% align MIDI to audio
[estimatedOns, estimatedOffs, nmat,dtw]=runPolyAlignment(audiofile, midifile, meansCovarsMat, voiceType);

% for
for v = 1 : 4
    ons=nonzeros(estimatedOns{v});
    offs=nonzeros(estimatedOffs{v});
    loc=1;
    n = 1 
    % Estimate f0 for a matrix (or vector) of amplitudes and frequencies
    [f0{v}{loc}, pwr{v}{loc}, t{v}{loc}, M{v}{loc}, xf{v}{loc}] = f0EstWeightedSumSpec(audiofile, ons(loc), offs(loc), nmat{v}(n,4));
    % Estimate note-wise perceptual values
    noteVals{v}{loc}=estimatePerceptualParamters([f0{v}{loc}],[pwr{v}{loc}],[xf{v}{loc}],[M{v}{loc}],sr,256,1,sig);
    loc=loc+1;
end

