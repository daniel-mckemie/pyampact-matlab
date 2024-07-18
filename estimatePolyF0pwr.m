%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% estimatedOns estimatedOffs]=estimatePolyF0pwr(audiofile, midifile)
%
% Description: 
%
% Inputs:

%
% Outputs:
%
% Dependencies:
%
% Automatic Music Performance Analysis and Analysis Toolkit (AMPACT)
% http://www.ampact.org
% (c) copyright 2017 Johanna Devaney (j@devaney.ca), all rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%% if no arguments %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 4
    voiceType = [2 1 1 1];    
end

if nargin < 3
    meansCovarsMa
    
    t='polySingingMeansCovars.mat';
end

if nargin < 2
    midifile = 'polyExample.mid';
end

if nargin < 1
    audiofile = 'polyExample.wav';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Initial DTW alignment stuff %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read MIDI file

