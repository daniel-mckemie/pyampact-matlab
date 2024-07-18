function [m,p,q,S,D,M,N] = alignmidiwav(MF,WF,TH,ST,width,tsr,nhar,wms)
% [m,p,q,S,D,M] = alignmidiwav(MF,WF,TH,ST)
%    Align a midi file to a wav file using the "peak structure
%    distance" of Orio et al. that use the MIDI notes to build 
%    a mask that is compared against harmonics in the audio.
%    MF is the name of the MIDI file, WF is the name of the wav file.
%    TH is the time step resolution (default 0.050).
%    ST is the similarity type: 0 (default) is triangle inequality;
%       1 is Orio-style "peak structure distance".
%    S is the similarity matrix.
%    [p,q] are the path from DP
%    D is the spectrogram, M is the midi-note-derived mask.
%    m is the map s.t. M(:,m) \approxeq D
% 2008-03-20 Dan Ellis dpwe@ee.columbia.edu

if nargin < 3
  % time resolution
  TH = 0.050;
end

if nargin < 4
  % time resolution
  ST = 0;
end

% Read the wav file (or MP3)
[pp,nn,ee] = fileparts(WF);
if strcmp(ee,'.mp3')
  [d, sr] = mp3read(WF);
else
  [d, sr] = audioread(WF);
end
if(size(d,2)) == 2; d = mean(d')'; end
% use sgram bins below 1k
targetsr = tsr;
srgcd = gcd(targetsr,sr);
dr = resample(d,targetsr/srgcd,sr/srgcd);

% Choose win length as power of 2 closest to 100ms
winms = wms;
fftlen = 2^round(log(winms/1000*targetsr)/log(2));


% actually take the spectrogram
win = fftlen;
ovlp = round(win - TH*targetsr);
D = abs(specgram(dr,fftlen,targetsr,win,ovlp));
filename = 'matlabD.csv';

% Write the matrix M to a CSV file
writematrix(D, filename);


% Build the MIDI-based mask
% Read the midi file on a sampled grid
N = samplemidi(MF, TH);
% Convert the MIDI piano roll into harmonics mask
nharms = nhar;
basenote = 1;
%width = 1.5; % semitones tolerance of specgram mask  (was 0.2)
tuning = 1.0;  % if he's flat, .98; 
M = notes2mask(N, fftlen, targetsr, nharms, basenote, width, tuning);
% Specify the file name
filename = 'matlabM.csv';

% Write the matrix M to a CSV file
writematrix(M, filename);
%%%%%%%
% Make sure there is an all-zero column before each note change
%onsetcols = 1+find(sum(max(0,M(:,(2:end))-M(:,1:(end-1)))) > 0);
%M(:,onsetcols-1) = 0;
%%%%%%%

% disp(size(M));
% disp('Spec from Matlab: ');
% disp(size(D));

% Calculate the peak-structure-distance similarity matrix
if ST == 1  
  S = orio_simmx(M,D);
else
  % or maybe just
  S = simmx(M,D);
end
% disp('S from Matlab: ');
% disp(size(S));

S = csvread('./pythonS_0609.csv');

%%%%
%%%% Threshold for matching a "silence" state 0..1
%silstatethresh = 0.4;
%S(onsetcols-1,:) = silstatethresh*max(S(:));
%%%%

% ensure no NaNs (only going to happen with simmx)
S(isnan(S(:))) = 0;

% Do the DP search
% disp(S);

[p,q] = dp(1-S);
filename = 'matlabP.csv';
writematrix(p, filename);
filename = 'matlabQ.csv';
writematrix(q, filename);
% disp(p);
% disp(size(p));
% disp(q);
% stopPlaying();
disp(TH);
% Plot the alignment
%imgsc(S);
%hold on; plot(q,p,'-r'); hold off

% map is indices into MIDI file that make it line up with spectrogram
%pp = [p,0];
for i = 1:size(D,2)
%  m(i) = pp(min(find([q,i]==i)));
if find(q==i)
  m(i) = p(min(find(q==i)));
else
    m(i)=1;
end
end
