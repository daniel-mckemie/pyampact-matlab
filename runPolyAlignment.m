function [estimatedOns estimatedOffs,nmat,dtw]=runPolyAlignment(audiofile, midifile, meansCovarsMat, voiceType)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% estimatedOns estimatedOffs]=runPolyAlignment(audiofile, midifile)
%
% Description: Main function for runing polyphonic MIDI-audio alignment
%              An intial DTW alignment is refined to estimate asychroncies 
%              between notated simultaneities
%
%               Note that this current version assumes that each note ends
%               immediately before it starts again (i.e., no rests)
%
% Inputs:
%  audiofile - audio file file
%  midifile - midi file
%  meansCovarsMat - specifies means and covariance matrix to use
%  voiceType - vector indicating which voice (or instrument) to use for
%              each musical line
%
% Outputs:
%  estimatedOns - cell array of onset times 
%  estimatedOffs - cell array of offset times
%
% Dependencies:
%  Ellis, D. P. W. 2003. Dynamic Time Warp (DTW) in Matlab. Available
%   from: http://www.ee.columbia.edu/~dpwe/resources/matlab/dtw/
%  Ellis, D. P. W. 2008. Aligning MIDI scores to music audio. Available
%   from: http://www.ee.columbia.edu/~dpwe/resources/matlab/alignmidiwav/
%  Toiviainen, P. and T. Eerola. 2006. MIDI Toolbox. Available from:
%   https://www.jyu.fi/hum/laitokset/musiikki/en/research/coe/materials
%          /miditoolbox/
%   Murphy, K. 1998. Hidden Markov Model (HMM) Toolbox for Matlab.
%    Available from http://www.cs.ubc.ca/~murphyk/Software/HMM/hmm.html 
%
% Automatic Music Performance Analysis and Analysis Toolkit (AMPACT)
% http://www.ampact.org
% (c) copyright 2014 Johanna Devaney (j@devaney.ca), all rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%% if no arguments %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4
    voiceType = [2 1 1 1];    
end

if nargin < 3
    meansCovarsMat='polySingingMeansCovars.mat';
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
nmatAll=midi2nmat(midifile);

if min(nmatAll(:,3)) == 0
    nmatAll(:,3)=nmatAll(:,3)+1;
end

for i = sort(unique(nmatAll(:,3)))'    
    nmat{i} = nmatAll(nmatAll(:,3)==i,:);
end

maxNotes=max(nmatAll(:,3));

%%%%%%%% Initialize HMM variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% needs to be here for calculations in initial DTW alignment
% starting state for HMM

for i = 1 : maxNotes
    startingState{i} = [1; zeros(3^i-1,1)];
end

% get transition matrix for HMM
[notes trans] = genPolyTrans(50, 0, 5);
for i = 1 : maxNotes
    notesInd{i} = cat(1, notes{i}{:})';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run DTW alignment using composite midifile
[align,spec,dtw] = runDTWAlignment(audiofile, midifile, 0.025);

% calculate how many voices change at each transition
%nmatAll(:,1)=floor(nmatAll(:,1)*1000)/1000;
[uniqueBeats, idx1, idx2] = unique(onset(nmatAll), 'first');
uniqueAlignOns = align.nmat(idx1, 1);
onsetMap = zeros(length(uniqueBeats),maxNotes); 
for i = 1 : length(uniqueBeats)
    %num = 1;
    for j = 1:maxNotes
        if sum(onset(nmat{j}) == uniqueBeats(i))
            onsetMap(i,j) = 1;
        end
        %num = num + 1;
    end
end

% create new onset map using alignment values
% THIS IS CURRENTLY ASSUMING THAT THERE ARE NO NOTATED RESTS
for i = 1 : size(onsetMap,1) % number of onsets
    for j = 1 : size(onsetMap,2) % number of voices
        if onsetMap(i,j) == 1, 
            onsMap2(i,j) = uniqueAlignOns(i);
        end
    end 
    lv2(i) = find(onsetMap(i,:), 1, 'first');
    onVals(i)=onsMap2(i,lv2(i));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%% Audio analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set paramters for audio analysis
offset1=0.125;
offset2=0.125;
[audio,sr]=audioread(audiofile);
audio=resample(audio,1,2); 
sr = sr/2;
tuning=estimateTuning(audio);
parameter.winLenSTMSP=441;
parameter.shiftFB = tuning;

% create a matrix of the notes in the audio in midi note numbers for each
% transition, as defined by onsetMap
for i = 1 : maxNotes
    idxCell{i}=1;
    pitches{1}(i,3)=nmat{i}(1,4)+tuning;
end
for i = 2 : size(onsetMap,1)
    for j = 1 : maxNotes
        if onsetMap(i,j) == 1
            pitches{i}(j,1)=nmat{j}(idxCell{j},4)+tuning;
            pitches{i}(j,2)=0;
            try
                pitches{i}(j,3)=nmat{j}(idxCell{j}+1,4)+tuning;
            end
            idxCell{j}=idxCell{j}+1;            
        else
            pitches{i}(j,1)=pitches{i-1}(j,3)+tuning;
            pitches{i}(j,2)=pitches{i-1}(j,3)+tuning;
            try
                pitches{i}(j,3)=pitches{i-1}(j,3)+tuning;
            end
        end
    end
end

% get means and covars for the singing voice
% differentiate for different voices
load(meansCovarsMat)
for i = 1 : size(nmat,2)
    [meansSeed{i} covarsSeed{i} versions]=genMeansCovars(notes, vals{i},voiceType);
end
% set the harmonics that are going to be considered
harmonics=[-1 0 1];
harmonics2=[-1 0 1 12 19 24 28 31 36];

% run audio analysis
fpitchAll=audio_to_pitch_via_FB(audio,parameter);
hop = length(audio)/size(fpitchAll,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%% NAME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize indexing cell array
for i = 1 : maxNotes
    idxCell{i}=1;
end
for i = 1 : length(onsetMap)
%for i = 2 : length(onsetMap)-1
    numVoices = sum(onsetMap(i,:),2);
    try
        fpitch{i}=fpitchAll(:,round((onVals(i)-offset1)*sr/hop):round((onVals(i)+offset2)*sr/hop));
    catch
        fpitch{i}=fpitchAll(:,max(1,round((onVals(i)-offset1)*sr/hop)):end);
    end
    numFrames(i)=size(fpitch{i},2);
    lengthSignal(i)=length(audio(max(1,round((onVals(i)-offset1)*sr)):max(round((onVals(i)+offset2)*sr),1)));
    [a,b,c]=find(onsetMap(i,:), size(nmat,2));
    num = 1;
    for j = b
        obs{i}(num,:)=db(sum(fpitch{i}(nmat{j}(idxCell{j},4)+harmonics,:)));
        if sum(onsetMap(i+1:end,j))~=0

            % db of sum fpitch vals - no harmonics            
            obs{i}(num+1,:)=db(sum(fpitch{i}(nmat{j}(idxCell{j}+1,4)+harmonics,:)));   

            % alternative features
            %             % db of mean fpitch vals - no harmonics
            %             db(mean(fpitch{i}(nmat{j}(idxCell{j},4)+harmonics,:)));
            %             db(mean(fpitch{i}(nmat{j}(idxCell{j}+1,4)+harmonics,:)));   
            % 
            %             % db of mean fpitch vals - harmonics
            %             db(mean(fpitch{i}(nmat{j}(idxCell{j},4)+harmonics2,:)));
            %             db(mean(fpitch{i}(nmat{j}(idxCell{j}+1,4)+harmonics2,:)));    
            % 
            %             % db of sum fpitch vals - harmonics
            %             db(sum(fpitch{i}(nmat{j}(idxCell{j},4)+harmonics2,:)));
            %             db(sum(fpitch{i}(nmat{j}(idxCell{j}+1,4)+harmonics2,:)));    

            idxCell{j}=idxCell{j}+1;
            
        else
             obs{i}(num+1,:)=db(sum(fpitch{i}(nmat{j}(idxCell{j},4)+harmonics,:)));
%              numVoices = numVoices-1;
%              b = b(b~=j);
        end
        num = num + 2;
    end
    
    if numVoices
        for j = 1 : size(versions{numVoices},1)
            if all(versions{numVoices}(j,:)==b);
                idx = j;
            end
        end
        
        % get appropriate trans, meansSeed, covarsSeed, and calculate mixmat
            curTrans = trans{numVoices};            

            curMeansSeed = meansSeed{3}{numVoices}{idx};
            curCovarsSeed = covarsSeed{3}{numVoices}{idx};
            mixmat = ones(length(curMeansSeed),1); 
            sState = startingState{numVoices};
            states = [1 2 3];

            if i == 1
                
                curTrans = curTrans(sum(notesInd{numVoices}==1,1)<1,sum(notesInd{numVoices}==1,1)<1);
                curMeansSeed = curMeansSeed(:,sum(notesInd{numVoices}==1,1)<1);
                curCovarsSeed = curCovarsSeed(:,:,sum(notesInd{numVoices}==1,1)<1);
                mixmat = mixmat(sum(notesInd{numVoices}==1,1)<1);
                sState = sState(sum(notesInd{numVoices}==1,1)<1);
                sState(1) = 1;
                notesIndTmp{i}=notesInd{numVoices}(:,sum(notesInd{4}==1,1)<1);
                states = [2 3];
                
%                 curTrans = curTrans(sum(notesInd{numVoices}~=3)>(maxNotes-1),:);
%                 curMeansSeed = curMeansSeed(:,sum(notesInd{numVoices}~=3)>(maxNotes-1));
%                 curCovarsSeed = curCovarsSeed(:,:,sum(notesInd{numVoices}~=3)>(maxNotes-1));
%                 mixmat = mixmat(sum(notesInd{numVoices}~=3)>(maxNotes-1));
%                 sState = sState(sum(notesInd{numVoices}~=3)>(maxNotes-1));
%                 notesIndTmp=notesInd{maxNotes}(:,sum(notesInd{numVoices}~=3)>(maxNotes-1));
            elseif i == length(onsetMap)
                curTrans = curTrans(sum(notesInd{numVoices}<3,1)>(numVoices-1),:);
                curMeansSeed = curMeansSeed(:,sum(notesInd{numVoices}<3,1)>(numVoices-1));
                curCovarsSeed = curCovarsSeed(:,:,sum(notesInd{numVoices}<3,1)>(numVoices-1));
                mixmat = mixmat(sum(notesInd{numVoices}<3,1)>(numVoices-1));
                sState = sState(sum(notesInd{numVoices}<3,1)>(numVoices-1));
                states = [1 2];
                notesIndTmp{i}=notesInd{numVoices}(:,sum(notesInd{numVoices}<3,1)>(numVoices-1));
            else
                notesIndTmp{i}=notesInd{numVoices};
            end
                 
            like1{i} = mixgauss_prob(obs{i}, curMeansSeed, curCovarsSeed, mixmat,1);
            like1{i}(:,1)=[1; zeros(length(like1{i}(:,end))-1,1)]; 
            like1{i}(:,end)=[zeros(length(like1{i}(:,end))-1,1); 1]; 
            vpath1{i}=viterbi_path(sState, curTrans, like1{i});
    end
    
    % for each note 
    % i is the note
    % b(j) is the voice
    for j = 1 : numVoices
        try
            noteVals{i}{j}=notesIndTmp{i}(j,vpath1{i});
        end
        for m = states
             try
                notePos{i}{j}(m)=find(noteVals{i}{j}==m,1,'last');
             catch
                 notePos{i}{j}(m)=notePos{i}{j}(m-1);
             end
        end        
    end
    
end




% % last note
numVoices=maxNotes;
curTrans = trans{numVoices};
idxEnd=sum(notesInd{numVoices}<3,1)>(numVoices-1);
curTrans = curTrans(idxEnd,idxEnd);

curMeansSeed = meansSeed{3}{numVoices}{1};
curMeansSeed = curMeansSeed(:,idxEnd);
            
curCovarsSeed = covarsSeed{3}{numVoices}{1};
curCovarsSeed = curCovarsSeed(:,:,idxEnd);
                
mixmat = ones(length(curMeansSeed),1); 
%mixmat = mixmat(sum(notesInd{numVoices}<3,1)>(numVoices-1));

sState = startingState{numVoices};
sState = sState(1:length(mixmat));
            
states = [1 2];


lastOffset=length(onsetMap)+1;
notesIndTmp{lastOffset}=notesInd{numVoices}(:,idxEnd);
fpitch{lastOffset}=fpitchAll(:,round((onVals(end)+offset1)*sr/hop):end);
numFrames(lastOffset)=size(fpitch{lastOffset},2);
lengthSignal(lastOffset)=length(audio(max(1,round((onVals(end)+offset1)*sr)):end));
num = 1;
for note = 1 : numVoices
    obs{lastOffset}(num,:)=db(sum(fpitch{lastOffset}(nmat{note}(idxCell{note},4)+harmonics,:)));
    obs{lastOffset}(num+1,:)=db(sum(fpitch{lastOffset}(nmat{note}(idxCell{note},4)+harmonics,:)))
    num = num + 2;
end

like1{lastOffset} = mixgauss_prob(obs{lastOffset}, curMeansSeed, curCovarsSeed, mixmat,1);
like1{lastOffset}(:,1)=[1; zeros(length(like1{lastOffset}(:,end))-1,1)]; 
like1{lastOffset}(:,end)=[zeros(length(like1{lastOffset}(:,end))-1,1); 1]; 
vpath1{lastOffset}=viterbi_path(sState, curTrans, like1{lastOffset});

for j = 1 : numVoices
        noteVals{lastOffset}{j}=notesIndTmp{lastOffset}(j,vpath1{lastOffset});
    
    for m = states
            notePos{lastOffset}{j}(m)=find(noteVals{lastOffset}{j}==m,1,'last');
%          catch
%              notePos{lastOffset}{j}(m)=notePos{lastOffset}{j}(m-1);
%          end
    end        
end




for i = 1 : length(onsetMap)
    for j = find(onsetMap(i,:)): sum(onsetMap(i,:))
%        if onsetMap(i,j) == 1 && sum(onsetMap(i+1:end,j))~=0
            noteSecs{i}{j}=notePos{i}{j}*lengthSignal(i)/numFrames(i)/sr+onVals(i)-offset1;
            if i > 1
                % check
                estimatedOffs{j}(i-1) = noteSecs{i}{j}(1);
            end
            estimatedOns{j}(i) = noteSecs{i}{j}(2);
%         else
%             estimatedOffs{j}(i)=0;
%             estimatedOns{j}(i)=0;
%        end
    end
end

for j = 1 : maxNotes
    noteSecs{lastOffset}{j}=notePos{lastOffset}{j}*lengthSignal(lastOffset)/numFrames(lastOffset)/sr+onVals(end)+offset1;
    estimatedOffs{j}(length(estimatedOns{j}))=noteSecs{lastOffset}{j}(1); 
end