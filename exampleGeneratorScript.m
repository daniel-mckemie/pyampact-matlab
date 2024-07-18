load SingingMeansCovars.mat
means=sqrtmeans; 
covars=sqrtcovars;

width=2;
targetsr=2000;

% audio file to be aligned
audiofile=('exampleOneNote.wav');

% MIDI file to be aligned
midifile=('exampleOneNote.mid');

% number of notes to align
numNotes1=1;
    
% vector of order of states (according to lyrics) in stateOrd and 
% corresponding note numbers in noteNum
%   1 indicates a rest at the beginning of ending of the note
%   2 indicates a transient at the beginning or ending of the note
%   3 indicates a steady state section
% the following encoding is for six syllables "A-ve Ma-ri-(i)-a"
%  syllable      A-ve Ma-ri-(i)-a
%  state type   13 23 23 23  3  31
%  note number  11 22 33 44  5  66
stateOrd1  = [1 3 1];
noteNum1 =   [1 1 1];

dtw1note = exampleGenerator(midifile, audiofile, numNotes1,stateOrd1,noteNum1, means,covars, width);
filename='example1noteWidth2TEST.xls';
plotSaveMask(dtw1note, audiofile, targetsr, filename)

return 
% audio file to be aligned
audiofile6=('example.wav');

% MIDI file to be aligned
midifile6=('example6note.mid');

% number of notes to align
numNotes6=6;
    
% vector of order of states (according to lyrics) in stateOrd and 
stateOrd6  = [1 3 2 3 2 3 2 3 3 3 1];
noteNum6 =   [1 1 2 2 3 3 4 4 5 6 6];

dtw6note = exampleGenerator(midifile6, audiofile6, numNotes6,stateOrd6,noteNum6, means,covars, width);
xlswrite('example6noteWidth2.xls',dtw6note.notemask)

% audio file to be aligned
audiofile3=('example3note.wav');

% MIDI file to be aligned
midifile3=('example3note.mid');

% number of notes to align
numNotes3=3;
    
% vector of order of states (according to lyrics) in stateOrd and 
stateOrd3  = [1 3 2 3 2 3];
noteNum3 =   [1 1 2 2 3 3];

dtw3note = exampleGenerator(midifile3, audiofile3, numNotes3,stateOrd3,noteNum3, means,covars, width);
xlswrite('example3noteWidth2.xls',dtw3note.notemask)


% audio file to be aligned
audiofilePoly=('exampleOneNote.wav');

% MIDI file to be aligned
midifilePoly=('polyExample1note.mid');

% number of notes to align
numNotes1=1;
    
% vector of order of states (according to lyrics) in stateOrd and 
% corresponding note numbers in noteNum
%   1 indicates a rest at the beginning of ending of the note
%   2 indicates a transient at the beginning or ending of the note
%   3 indicates a steady state section
% the following encoding is for six syllables "A-ve Ma-ri-(i)-a"
%  syllable      A-ve Ma-ri-(i)-a
%  state type   13 23 23 23  3  31
%  note number  11 22 33 44  5  66
stateOrd1  = [1 3 1];
noteNum1 =   [1 1 1];

dtwPoly1note = exampleGenerator(midifilePoly, audiofilePoly, numNotes1,stateOrd1,noteNum1, means,covars, width);
xlswrite('examplePoly1noteWidth2.xls',dtwPoly1note.M)