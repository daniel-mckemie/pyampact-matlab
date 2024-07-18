function [align,spec,dtw] = runDTWAlignment(audiofile, midorig, tres,width,targetsr,nharm,winms)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% align = runDTWAlignment(sig, sr, midorig, tres, plot)
%
% Description: 
%  Performs a dynamic time warping alignment between specified audio and
%  MIDI files and returns a matrix with the aligned onset and offset times 
%  (with corresponding MIDI note numbers) and a spectrogram of the audio
%
% Inputs:
%  sig - audio file
%  midorig - midi file
%  tres - time resolution for MIDI to spectrum information conversion
%
% Outputs: 
%  align - dynamic time warping MIDI-audio alignment structure
%   align.on - onset times
%   align.off - offset times
%   align.midiNote - MIDI note numbers
%  spec - sepctrogram 
%
% Dependencies:
%  Ellis, D. P. W. 2003. Dynamic Time Warp (DTW) in Matlab. Available 
%   from: http://www.ee.columbia.edu/~dpwe/resources/matlab/dtw/ 
%  Ellis, D. P. W. 2008. Aligning MIDI scores to music audio. Available 
%   from: http://www.ee.columbia.edu/~dpwe/resources/matlab/alignmidiwav/ 
%  Toiviainen, P. and T. Eerola. 2006. MIDI Toolbox. Available from:
%   https://www.jyu.fi/hum/laitokset/musiikki/en/research/coe/materials
%          /miditoolbox/
%
% Automatic Music Performance Analysis and Analysis Toolkit (AMPACT) 
% http://www.ampact.org
% (c) copyright 2011 Johanna Devaney (j@devaney.ca), all rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



if ~exist('tres', 'var'),  tres = 0.025; end

if ~exist('width', 'var'),   width = 1; end

if ~exist('targetsr', 'var'),   targetsr = 2000; end
    
if ~exist('nharm', 'var'), nharm = 4;  end

if ~exist('winms', 'var'), winms = 100; end

mid = midorig;

% run alignment using peak structure distance as a feature
[dtw.M,dtw.MA,dtw.RA,dtw.S,dtw.D,dtw.notemask,dtw.pianoroll] = alignmidiwav(mid,...
    audiofile,tres,1,width,targetsr,nharm,winms);

spec=dtw.D;

% read midi file and map the times in the midi file to the audio
align.nmat = midi2nmat(mid);
align.nmat(:,7) = align.nmat(:,6) + align.nmat(:,7);
disp(align.nmat(:,6:7));
disp((dtw.MA-1)*tres);
disp((dtw.RA-1)*tres);
align.nmat(:,1:2) = maptimes(align.nmat(:,6:7),(dtw.MA-1)*tres,(dtw.RA-1)*tres);


% create output alignment 
align.on = align.nmat(:,1);
align.off = align.nmat(:,2);
align.midiNote = align.nmat(:,4);
