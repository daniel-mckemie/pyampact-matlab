function nm = midiToolboxNM(file_name)
% returns the same matrix that you get from the midi toolbox

import edu.columbia.ee.csmit.MidiKaraoke.*;
import java.io.File;
import javax.sound.midi.*;

%file_name = '../karaoke files/mk_kar/202.kar';



midiFile = File(file_name);
seq = MidiSystem.getSequence(midiFile);

% get the number of ticks/quarter note, which I assume is the
% 'beat' in the nm
ticksPerQuarterNote = seq.getResolution();

pianoRoll = PianoRollViewParser.parse(seq);

notes = pianoRoll.getNotesDoubles;

nm = zeros(size(notes,1),7);

nm(:,1) = notes(:,4)./ticksPerQuarterNote; % start beats
nm(:,2) = notes(:,5)./ticksPerQuarterNote; % duration beats
nm(:,3) = notes(:,3)+1; % channel
nm(:,4) = notes(:,1); % pitch
nm(:,5) = notes(:,2); % velocity
nm(:,6) = notes(:,6); % start seconds
nm(:,7) = notes(:,7); % duration seconds



