function res = Loudness_TimeVaryingSound_Zwicker(signal, FS, type, fieldtype, x_ratio, t_duration, show)

%%%%%%%%%%%%%
% FUNCTION:
%   Calculation of loudness for time-varying sounds, following the model of
%   Zwicker and Fastl (1999).
%   See reference for more details.
%
% USE:
%   res = Loudness_TimeVaryingSound_Zwicker(signal, FS, type, fieldtype, x_ratio, t_duration, show)
% 
% INPUT:
%   signal    : acoustic signal, monophonic (Pa)
%   FS        : sampling frequency (Hz)
%   type      : (optional parameter) 'mic' (default value) for omnidirectional sound
%               recording, 'head' for dummy head measurement
%   fieldtype : 'free' (default) for free field, 'diffuse' for diffuse field
%   x_ratio   : percentage x used to compute Nx and Lx (percent) - default value is 5 % - see output
%   t_duration: duration t used to compute Nt and Lt (second) - default value is 0.030 sec. - see output
%   show      : optional parameter for some figures display.
%            May be false (disable, default value) or true (enable).
% 
% OUTPUT:
%   res    : structure which contains the following fields:
%             - frequency : frequency vector of central frequencies of ERB bands (Hz)
%             - time : time vector in seconds
%             - InstantaneousLoudness: instantaneous loudness (sone) vs time
%             - Nmax : maximum of instantaneous loudness (sone)
%             - Nx   : loudness exceeded during x percent of the signal (x is
%               the value of the input variable named x_ratio)
%             - Nt   : loudness exceeded during t seconds of the signal (t is
%               the value of the input variable named t_duration)
%             - InstantaneousLoudnessLevel: instantaneous loudness level (phon) vs time
%             - Lmax : maximum of instantaneous loudness level (sone)
%             - Lx   : loudness level exceeded during x percent of the signal (x is
%               the value of the input variable named x_ratio)
%             - Lt   : loudness level exceeded during t seconds of the signal (t is
%               the value of the input variable named t_duration)
%             - 
%             - InstantaneousSpecificLoudness: specific loudness (sone/ERB) vs time and frequency
% 
%   


%             - LTL: long-term loudness (sone) vs time
%             - STLmax: max of STL value (sone)
%             - LTLmax: max of LTL value (sone)
%             - InstantaneousLoudnessLevel: instantaneous loudness level (phon) vs time
%             - STLlevel: short-term loudness level (phon) vs time
%             - LTLlevel: long-term loudness level (phon) vs time
%             - STLlevelmax: max of STL level value (phon)
%             - LTLlevelmax: max of LTL level value (phon)
% REFERENCE: 
% Zwicker E. et Fastl H., "Psychoacoustics: Facts and models",
% 2nd Edition, Springer-Verlag, Berlin, 1999
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%
% function res = sonie_NonStationnaire_Zwicker(signal, FS, type, show)
%
% Calcul de la sonie d'un son de sonie variable dans le temps selon la
% procédure proposée par fastl (dérivé de Zwicker strationnaire) avec
% correction de Munich
%
% Entrées:
%   signal  :  signal en Pa
%   FS      :  fréquence d'échantillonnage en Hz
%   type    :  type de prise de son ( 'mic' ou 'head' ) ('mic' par défaut)
% fieldtype :  'free' ou 'diffuse' selon le cas ('free' par défaut)
%   show    :  si show = true affichage des figures (false par défaut)
%
% Sorties:
%   res.phonieMax: max de la phonie instantanée
%   res.phonieN5: niveau de phonie dépassée pendant 5 % du temps (seuil sur sones puis conversion en phones)
%
% Fonction créée à partir de la fonction fastl.m - 2009
%
% réf: Zwicker E. et Fastl H., "Psychoacoustics: Facts and models",
%      2nd Edition, Springer-Verlag, Berlin, 1999


%% Pre-processing

if nargin < 2,
    help Loudness_TimeVaryingSound_Zwicker;
    error('Not enough arguments');
end;

if nargin < 3,  % default is microphone measure
    type = 'mic'; 
end

if nargin < 4,  % default sound filed type is 'free'
    fieldtype = 'free';
end;

if nargin < 5,  % default x_ratio
    x_ratio = 5; % 5 percent
end;

if nargin < 6,  % default t_duration
    t_duration = 0.030;  % 30ms
end;

if nargin < 7,  % disable display
    show = false; 
end;

sig = signal(:);
fs = FS;


%% Parameters and constant settings

dt   = 0.002;   % temporal step for calculations (seconds)
tfen = 0.002;   % analysis window length (seconds)

% Quadripole constants
R1 = 35e3; % Ohm
R2 = 20e3; % Ohm
C1 = 0.7e-6; % Farad
C2 = 1e-6; % Farad

T1 = R1*C1;
T2 = R2*C2;
T3 = R1*(C1+C2);

% cut-off frequencies of the bands of interest 
Fc = [ 22 45 90 180 280 355 450 560 710 900 1120 1400 ...
       1800 2242 2799 3550 4500 5600 7100 9000 11200 14000 15500];

% Definitions for elliptic filters which will be designed
% Design is made in order to have same power in the bands Fc
% as when using an FFT of length 48000 on a white noise 

% Lower bound frequency
F1 = [ 26 57 101 192 295 370 471 582 737 916 1135 1425 ...
       1821 2260 2804 3550 4500 5600 7100 9000 11200 14000];
   
% Upper bound frequency
F2 = [ 36 76 161 257 341 429 540 683 873 1105 1383 1774 ...
       2220 2800 3555 4500 5600 7100 9000 11200 14000 15500];

% Ranges of 1/3 octave band levels for correction at low frequencies
% according to equal loudness contours
rap = [45 55 65 71 80 90 100 120 ];

% Correction of critical band levels at low frequencies according to 
% equal loudness contours within the eight ranges defined by RAP
dll = [ -4.4 -2.0 -1.0; 
        -4.2 -1.9 -0.9;
        -4.1 -1.8 -0.8;
        -4.0 -1.6 -0.7;
	    -3.9 -1.4 -0.6;
        -3.8 -1.2 -0.5;
        -3.7 -1.1 -0.4;
        -3.6 -1.0 -0.3];
    
% Critical band rate level at absolute threshold without taking into
% account the transmission characteristics of the ear
les = [ 30 18 12 8 7 6 5 4 3 3 3 3 3 3 3 3 3 3 3 3];

% Correction of levels according to the transmission characteristics of the ear
ao = [ 0 0 0 0 0 0 0 0 0 0 -0.5 -1.6 -3.2 -5.4 -5.6 -4 -1.5 2 5 12];

% Level differences between free and diffuse sound fields
DDF = [0 0 0.5 0.9 1.2 1.6 2.3 2.8 3 2 0 -1.4 -2 -1.9 -1 0.5 3 4 4.3 4];

% Adaptation of 1/3 octave band levels to the corresponding critical band levels (DCB)
dlt = [ -0.25 -0.6 -0.8 -0.8 -0.5 0 0.5 1.1 1.5 1.7 1.8 1.8 1.7 1.6 1.4 1.2 0.8 0.5 0 -0.5]; 

% Range of specific loudness for the determination of the steepness of the
% upper slopes in the specific loudness - critical band rate pattern (RNS)
lim = [ 21.5 18 15.1 11.5 9 6.1 4.4 3.1 2.13 1.36 ...
        0.82 0.42 0.3 0.22 0.15 0.1 0.035 0];
    
% Steepness of the upper slopes in the specific loudness - critical band
% rate pattern for the ranges RNS as a function of the number of the
% critical band (USL)
fls = [ 13.0 8.20 6.30 5.50 5.50 5.50 5.50 5.50;
        9.00 7.50 6.00 5.10 4.50 4.50 4.50 4.50;
        7.80 6.70 5.60 4.90 4.40 3.90 3.90 3.90;
	    6.20 5.40 4.60 4.00 3.50 3.20 3.20 3.20;
	    4.50 3.80 3.60 3.20 2.90 2.70 2.70 2.70;
	    3.70 3.00 2.80 2.35 2.20 2.20 2.20 2.20;
	    2.90 2.30 2.10 1.90 1.80 1.70 1.70 1.70;
	    2.40 1.70 1.50 1.35 1.30 1.30 1.30 1.30;
	    1.95 1.45 1.30 1.15 1.10 1.10 1.10 1.10;
	    1.50 1.20 0.94 0.86 0.82 0.82 0.82 0.82;
	    0.72 0.67 0.64 0.63 0.62 0.62 0.62 0.62;
	    0.59 0.53 0.51 0.50 0.42 0.42 0.42 0.42;
	    0.40 0.33 0.26 0.24 0.22 0.22 0.22 0.22;
	    0.27 0.21 0.20 0.18 0.17 0.17 0.17 0.17;
	    0.16 0.15 0.14 0.12 0.11 0.11 0.11 0.11;
	    0.12 0.11 0.10 0.08 0.08 0.08 0.08 0.08;
	    0.09 0.08 0.07 0.06 0.06 0.06 0.06 0.05;
	    0.06 0.05 0.03 0.02 0.02 0.02 0.02 0.02];
  
% Physical constants
I0 = 0.964e-12;
RC = 415;       % air impedance 

% add some silence at the end of the signal
sig(end : round( end + 0.3 * fs + tfen * fs)) = 0;

pts = length(sig);                  % nb of samples
step = round(fs * dt);              % number of samples between two calculations of loudness
winstep = floor(fs * tfen);         % number of samples of analysis window
ncl = floor((pts - winstep) / step);% number of samples of output from calculation
t = (0 : ncl-1) * step + 1;         % index of the calculation windows start
res.time = t / fs;                  % time vector


%% Filtering

[ b, a ] = butter( 6, 1000 / (2 * pi * fs)); % low-pass envelope filter

% band-pass filtering
[ c, d ] = ellip( 2, 0.05, 100, [F1(1) F2(1)] * 2 / fs);    % 1st filter coefficients
va = filter(c, d, sig);                                     % first band-pass filter
va2 = 10^(-100) + filter( b, a, abs(va)).^2;

[ c, d ] = ellip( 2, 0.05, 100, [F1(2) F2(2)] * 2 / fs);    % 2nd filter coefficients
vb = filter( c, d, sig);
vi2 = va2 + filter( b, a, abs(vb)).^2;                      % 1st band is sum of the 2 filters
xiq = zeros( ncl, 21);

for q = 1:ncl,        % temporal envelope
    xiq( q, 1) = 10 * log10(mean(vi2(t(q) : (t(q) + winstep))) / (RC * I0));
end;

for i = 2:21,       % loop from 2nd to 21st band
    no = 3;
    
    if i > 8,
        no = 4; 
    end;
    
    if i > 12, 
        no = 5; 
    end;
    
    [ c, d ] = ellip( no, 0.05, 100, [F1(i+1) F2(i+1)] * 2 / fs);
    
    vi = filter( c, d, sig);    
    vi2 = 1e-100 + filter( b, a, abs(vi)).^2;
    
    % in every band, calculation of the level every dt second
    for q = 1:ncl,
        xiq( q, i) = 10 * log10(mean(vi2(t(q) : (t(q) + winstep))) / (RC * I0));
    end;
end;


%% Loudness computation

% main loudness for ncl points
for q = 1 : ncl,
    
    le = xiq( q, 1 : 20);
    
    for i = 1:3, % correction for first 3 bands from their levels
        j = find((rap' - dll( :, i)) > le(i), 1, 'first');
        
        if isempty(j), 
            j = length(rap); 
        end;
        
	    le(i) = le(i) + dll( j, i);
    end;
    
    switch type,
        case 'mic',  % Microphone: outer ear correction is used
            le = (le' - ao' - dlt')';

        case 'head', % Dummy head: ear correction is already taken into the recording
            le = (le' - dlt')';

        otherwise,
            error('"type" parameter is not valid');

    end;

    % Zwicker constants
    No = 0.068;
    k = 0.23;
    s = 0.5;
    
    % Main loudness calculation
    F = No * (s^-k) * (10.^(k .* les / 10));
    
    % field type corrections
    switch fieldtype,
        case 'free',
            krn = F' .* (((1 - s) + s * (10.^(0.1 * (le' - les')))).^k - 1);
            
        case 'diffuse',
            krn = F' .* (((1 - s) + s * (10.^(0.1 * (le' + DDF' - les')))).^k - 1);
            
        otherwise,
            error('"fieldtype" parameter is not valid');
    end;
    
    krn( le < les ) = 0; % loudness values inferior to threshold are set to zero
    
    % correction of specific loudness within the first critical band taking
    % into account the dependence of absolute threshold within the band
    korry = 0.4 + 0.32 * krn(1)^0.2;
    
    if korry > 1, 
        korry = 1; 
    end
    
    krn(1) = krn(1) * korry;
    xiq( q, 1 : 21) = [krn' 0]; % store calculation result
end

%% Quadripol temporal response for main loudness

p = (T2 + T3) / (T1 * T2);
q = 1 / (T1 * T2);
lam1 = - p / 2 + sqrt(p * p / 4 - q);
lam2 = - p / 2 - sqrt(p * p / 4 - q);
den = T2 * (lam1 - lam2);
e1 = exp(lam1 * dt);
e2 = exp(lam2 * dt);
B0 = (e1 - e2) / den;
B1 = ((T2 * lam2 + 1) * e1 - (T2 * lam1 + 1) * e2) / den;
B2 = ((T2 * lam1 + 1) * e1 - (T2 * lam2 + 1) * e2) / den;
B3 = (T2 * lam1 + 1) * (T2 * lam2 + 1) * (e1 - e2) / den;
B4 = exp(- dt / T3);
B5 = exp(- dt / T2);
niq = zeros( ncl, 21);

for i = 1:21,
    ui = xiq( :, i);
    u0 = 0;
    u2 = 0;
    
    for q = 1 : ncl,
        if ui(q) < u0,
            if u0 > u2,
                u0dt = u0 * B2 - u2 * B3;
                u2dt = u0 * B0 - u2 * B1;
            else
                u0dt = u0 * B4;
                u2dt = u0dt;
            end;
            
        else
        u0dt = ui(q);
            if u0dt > u2,
                u2dt = (u2 - ui(q)) * B5 + ui(q);
            else
               u2dt = ui(q);
            end;
        end;
        
        if ui(q) > u0dt,
            u0dt = ui(q);
        end;
        
        if u2dt > u0dt,
            u2dt = u0dt;
        end;
        
        u0 = u0dt;
        u2 = u2dt;
        niq( q, i) = u0;
    end;
end;

prec = 50;  % frequency axis sampling
InstantaneousSpecificLoudness = zeros(ncl, 22*prec);
n_tot = zeros(1, ncl);

% loudness is processed for each q
for q = 1:ncl,
    
    krn = niq( q, :);
    ns = zeros( 21, 22*prec);
    
    for i = 1:21, % specific loudness
        n_up =  krn(i) * ones( 1, prec) ;
        z = i : (1/prec) : i+1;
        z(end) = [];
        
        for nj = find(lim <= krn(i)),
            
            ig = i; 
            if ig > 8,
                ig = 8;
            end;
            
            dz = (n_up(end) - lim(nj)) / fls( nj, ig);
            z = [z z(end) + dz];
            n_up = [n_up lim(nj)];
        end;
        
        z = [z 23];
        n_up = [n_up 0];
        
        if (sum(n_up) / prec) > 0.01,  % case "partial" loudness > 0.01 sone
            ns(i, i*prec : end) = interp1( z*prec, n_up, i*prec : 22*prec);
        end;
        
    end;
    
    ns = max(ns);  % max in every band - vector length is thus 22*prec
    n_tot(q) = sum(ns) / prec;     % total loudness at current time q
    InstantaneousSpecificLoudness(q, :) = ns;
end;

% output storage
res.InstantaneousSpecificLoudness = InstantaneousSpecificLoudness(:,prec:end-1);

f = [];
for i = [1, 3 : length(Fc) - 1],
    fTemp = linspace( Fc(i), Fc(i+1), prec+1);
    f = [f fTemp(2:end)];
end;

res.frequency = f; % frequency vector


%% Filtering to get Instantaneous loudness

fecl = round(fs / step);
[b, a] = butter( 3, 1000 / (20 * pi * fecl));
nq = filter( b, a, n_tot);
res.InstantaneousLoudness = nq;
res.Nmax = max(nq);


%% Conversion from sone to phon

phq = gene_sone2phon_ISO532B(nq);

phq( phq < 0 ) = 0;
phq( phq < 3 ) = 3;

res.InstantaneousLoudnessLevel = phq;
res.Lmax = max(phq); 



%% Nx computation
X_index = floor( (100-x_ratio)/100 * ncl );
nq_sort = sort( nq );
Nx = nq_sort( X_index );

res.Nx = Nx;


%% Nt computation
p_t = t_duration / dt;
X_index = ncl - p_t;
Nt = nq_sort( X_index );

res.Nt = Nt;

%% Lx computation
X_index = floor( (100-x_ratio)/100 * ncl );
nq_sort = sort( phq );
Lx = nq_sort( X_index );

res.Lx = Lx;

%% Lt computation
p_t = t_duration / dt;
X_index = ncl - p_t;
Lt = nq_sort( X_index );

res.Lt = Lt;


%% Optional displays

if show == true,
    figure;
    t = (0 : length(sig)-1) ./ fs;
    xmax = res.time(end);
    subplot( 3, 1, 1), plot( t, sig); ax = axis; axis([0 xmax ax(3) ax(4)]); 
        title('Signal'); ylabel('Amplitude (Pa)');
    subplot( 3, 1, 2), plot( res.time, res.InstantaneousLoudnessLevel); 
    ax = axis; axis([0 xmax ax(3) ax(4)]);
        title('Instantaneous Loudness Level'); ylabel('Loudness level (phon)'); grid on;
        text(res.time(end) * 0.7, res.Lmax - 10, ['Lmax = ' num2str(res.Lmax, 4)]);
    subplot( 3, 1, 3), plot( res.time, res.InstantaneousLoudness); ax = axis; axis([0 xmax ax(3) ax(4)]);
        title('Instantaneous Loudness'); xlabel('Time (s)');
        ylabel('Loudness (sone)'); grid on;
        text(res.time(end) * 0.7, res.Nmax ./ 2, ['Nmax = ' num2str(res.Nmax, 3)]);
    
    figure;
    mesh(res.time, res.frequency, res.InstantaneousSpecificLoudness'); view( 60, 60);
        title('Instantaneous Specific Loudness'); xlabel('Time (s)');
        ylabel('Frequency (Hz)');
        zlabel('Specific loudness (sone/Hz)');
end;
