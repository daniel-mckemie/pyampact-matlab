function [vibratoDepth, vibratoRate]=calculateVibrato(noteVals,sr)

L = length(noteVals); % Length of signal
Y = fft(noteVals)/L;  % Run FFT on normalized note vals
w = [0:L-1]*sr/L;     % Set FFT frequency grid

[vibratoDepthTmp, noteVibratOpos] = max(abs(Y));    % Find the max value and its position
vibratoDepth =vibratoDepthTmp*2; % Multiply the max by 2 to find depth (above and below zero)
vibratoRate = w(noteVibratOpos); % Index into FFT frequency grid to find position in Hz

% % max(fft(f0trace))/length(f0trace)
% % maxpos(fft(f0trace))-1/(length(f0trace)*timestep)
% vibrato=fft(noteVals);
% [vibratoDepthTmp noteVibratOpos] = max(abs(vibrato));
% vibratoDepth =vibratoDepthTmp/length(noteVals)*2;
% % vibratoRate = (noteVibratOpos-1)/(length(noteVals)*timestep);
% vibratoRate = (noteVibratOpos-1)/(length(noteVals)*timestep);i