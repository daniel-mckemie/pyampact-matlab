load SingingMeansCovars.mat
means=sqrtmeans; 
covars=sqrtcovars;

winms = [100, 100, 100, 100, 100, 100, 200, 200, 200]; 
targetsr = [2000, 2000, 2000, 4000, 4000, 4000, 4000, 4000, 4000];
nharm = [1 1 3 1 1 3 1 1 3]; 
width = [0 1 3 0 1 3 0 1 3];

% %% monophonic1note
% 
% % audio file to be aligned
% audiofile=('exampleOneNote.wav');
% 
% % MIDI file to be aligned
% midifile=('exampleOneNote.mid');
% 
% % number of notes to align
% numNotes1 = 1;
% 
% % vector of order of states (according to lyrics) in stateOrd and numNotes
% stateOrd1  = [1 3 1];
% noteNum1 =   [1 1 1];
% 
% for i = 1 : length(winms)
%     dtw = exampleGenerator(midifile, audiofile, numNotes1,stateOrd1,noteNum1, means,covars, width(i),targetsr(i), nharm(i),winms(i));
%     filename1=sprintf('monophonic1note-win%dsr%dh%dw%d',winms(i),targetsr(i),nharm(i),width(i));
%     xlswrite(filename1,dtw.notemask)
%     filename2=sprintf('monophonic1note-pr');
%     xlswrite(filename2,dtw.pianoroll)
% end
% 
% %% monophonic3notes
% 
% % audio file to be aligned
% audiofile3=('example3note.wav');
% 
% % MIDI file to be aligned
% midifile3=('example3note.mid');
% 
% % number of notes to align
% numNotes3=3;
%     
% % vector of order of states (according to lyrics) in stateOrd and numNotes
% stateOrd3  = [1 3 2 3 2 3];
% noteNum3 =   [1 1 2 2 3 3];
% 
% for i = 1 : length(winms)
%     dtw = exampleGenerator(midifile3, audiofile3, numNotes3,stateOrd3,noteNum3, means,covars, width(i),targetsr(i), nharm(i),winms(i));
%     filename1=sprintf('monophonic3notes-win%dsr%dh%dw%d',winms(i),targetsr(i),nharm(i),width(i));
%     xlswrite(filename1,dtw.notemask)
%     filename2=sprintf('monophonic3notes-pr');
%     xlswrite(filename2,dtw.pianoroll)
% end
% 
% %% monophonic6notes
% 
% % audio file to be aligned
% audiofile6=('example.wav');
% 
% % MIDI file to be aligned
% midifile6=('example6note.mid');
% 
% % number of notes to align
% numNotes6=6;
%     
% % vector of order of states (according to lyrics) in stateOrd and 
% stateOrd6  = [1 3 2 3 2 3 2 3 3 3 1];
% noteNum6 =   [1 1 2 2 3 3 4 4 5 6 6];
% 
% for i = 1 : length(winms)
%     dtw = exampleGenerator(midifile6, audiofile6, numNotes6,stateOrd6,noteNum6, means,covars, width(i),targetsr(i), nharm(i),winms(i));
%     filename1=sprintf('monophonic6notes-win%dsr%dh%dw%d',winms(i),targetsr(i),nharm(i),width(i));
%     xlswrite(filename1,dtw.notemask)
%     filename2=sprintf('monophonic6notes-pr');
%     xlswrite(filename2,dtw.pianoroll)
% end

% % %% polyphonic4voices1note
% 
% % audio file to be aligned
% audiofilePoly1note=('exampleOneNote.wav');
% 
% % MIDI file to be aligned
% midifilePoly1note=('polyExample1note.mid');
% 
% % number of notes to align
% numNotes1=1;
%     
% % vector of order of states (according to lyrics) in stateOrd and 
% stateOrd1  = [1 3 1];
% noteNum1 =   [1 1 1];
% 
% for i = 1 : length(winms)
%     dtw = exampleGenerator(midifilePoly1note, audiofilePoly1note, numNotes1,stateOrd1,noteNum1, means,covars, width(i),targetsr(i), nharm(i),winms(i));
%     filename1=sprintf('polyphonic4voices1note-win%dsr%dh%dw%d',winms(i),targetsr(i),nharm(i),width(i));
%     xlswrite(filename1,dtw.notemask)
%     filename2=sprintf('polyphonic4voices1note-pr');
%     xlswrite(filename2,dtw.pianoroll)
% end
% 
% %% polyphonic3voices1note
% 
% % audio file to be aligned
% audiofilePoly1note=('exampleOneNote.wav');
% 
% % MIDI file to be aligned
% midifilePoly1note=('polyExample3voices1note.mid');
% 
% % number of notes to align
% numNotes1=1;
%     
% % vector of order of states (according to lyrics) in stateOrd and 
% stateOrd1  = [1 3 1];
% noteNum1 =   [1 1 1];
% 
% for i = 1 : length(winms)
%     dtw = exampleGenerator(midifilePoly1note, audiofilePoly1note, numNotes1,stateOrd1,noteNum1, means,covars, width(i),targetsr(i), nharm(i),winms(i));
%     filename1=sprintf('polyphonic3voices1note-win%dsr%dh%dw%d',winms(i),targetsr(i),nharm(i),width(i));
%     xlswrite(filename1,dtw.notemask)
%     filename2=sprintf('polyphonic3voices1note-pr');
%     xlswrite(filename2,dtw.pianoroll)
% end
% 
% %% polyphonic2voices1note
% 
% audio file to be aligned
% audiofilePoly1note=('exampleOneNote.wav');
% 
% % MIDI file to be aligned
% midifilePoly1note=('polyExample2voices1note.mid');
% 
% % number of notes to align
% numNotes1=1;
%     
% % vector of order of states (according to lyrics) in stateOrd and 
% stateOrd1  = [1 3 1];
% noteNum1 =   [1 1 1];
% 
% for i = 1 : length(winms)
%     i
%     dtw = exampleGenerator(midifilePoly1note, audiofilePoly1note, numNotes1,stateOrd1,noteNum1, means,covars, width(i),targetsr(i), nharm(i),winms(i));
%     filename1=sprintf('polyphonic2voices1note-win%dsr%dh%dw%d',winms(i),targetsr(i),nharm(i),width(i));
%     xlswrite(filename1,dtw.notemask)
%     filename2=sprintf('polyphonic2voices1note-pr');
%     xlswrite(filename2,dtw.pianoroll)
% end

 
%% tavernOpeningMeasure

% audio file to be aligned
audiofilePoly1note=('exampleOneNote.wav');

% MIDI file to be aligned
midifilePoly1note=('tavernOpeningMeasure.mid');

% number of notes to align
numNotes1=1;
    
% vector of order of states (according to lyrics) in stateOrd and 
stateOrd1  = [1 3 1];
noteNum1 =   [1 1 1];

for i = 1 : length(winms)
    dtw = exampleGenerator(midifilePoly1note, audiofilePoly1note, numNotes1,stateOrd1,noteNum1, means,covars, width(i),targetsr(i), nharm(i),winms(i));
    filename1=sprintf('tavernOpeningMeasure-win%dsr%dh%dw%d',winms(i),targetsr(i),nharm(i),width(i));
    xlswrite(filename1,dtw.notemask)
    filename2=sprintf('tavernOpeningMeasure-pr');
    xlswrite(filename2,dtw.pianoroll)
end

%% tavernClosing2Measures

% audio file to be aligned
audiofilePoly1note=('exampleOneNote.wav');

% MIDI file to be aligned
midifilePoly1note=('tavernClosing2Measures.mid');

% number of notes to align
numNotes1=1;
    
% vector of order of states (according to lyrics) in stateOrd and 
stateOrd1  = [1 3 1];
noteNum1 =   [1 1 1];

for i = 1 : length(winms)
    dtw = exampleGenerator(midifilePoly1note, audiofilePoly1note, numNotes1,stateOrd1,noteNum1, means,covars, width(i),targetsr(i), nharm(i),winms(i));
    filename1=sprintf('tavernClosing2Measures-win%dsr%dh%dw%d',winms(i),targetsr(i),nharm(i),width(i));
    xlswrite(filename1,dtw.notemask)
    filename2=sprintf('tavernClosing2Measures-pr');
    xlswrite(filename2,dtw.pianoroll)
end
