function res=estimatePerceptualParamters(f0Vals,pwrVals,F,M,SR, hop,gtFlag,X)


% f0Vals - f0 estimates (yin, dct, or if)
% pwrVals - pwr estimates (yin, dct, or if)
% F - frequency matrix
% M - magnitude matrix
% SR - sampling rate of original audio file
% hopF0 - hop size of F0 estimates
% hop - hop size of M matrix
% X - original audio signal (optional, if absent will be constructed from
%   the M and F matrices


if nargin < 8
    win_s = 0.064;
    WIN = round(win_s * SR); 
    nHOP = round(WIN / 4);

    M2=M(find(sum(M,2)),:);
    F2=F(find(sum(M,2)),:);

    X = synthtrax(F2, M2, SR, WIN, nHOP);
end
 
% perceived pitch
res.ppitch=perceivedPitch(f0Vals, SR/hop, 1);

% jitter
for i = 1 : length(f0Vals) - 1
    tmpJitter(i)=f0Vals(i+1)-f0Vals(i);
end
res.jitter=mean(abs(tmpJitter));

%vibrato rate and depth 
[res.vibratoDepth, res.vibratoRate]=calculateVibrato((f0Vals-mean(f0Vals)),SR/hop);

% perceived loudness 
%res.loudnessMoore = Loudness_TimeVaryingSound_Moore(X, SR);
% res.STLmax=res.loudnessMoore.STLmax;
% res.LTLmax=res.loudnessMoore.LTLmax;
% res.STLmax=[];
% res.LTLmax=[];
%res.loudnessZwicker = Loudness_TimeVaryingSound_Zwicker(X, SR);
% [res.totalLoudness,res.specLoudness,Estim,Ethq]=calcTotalLoudness(X);


% shimmer
for i = 1 : length(pwrVals) - 1
    tmpShimmer(i)=10*log10(pwrVals(i+1)/pwrVals(1));
end
res.shimmer=mean(abs(tmpShimmer));
res.pwrVals=10*log10(pwrVals);
res.f0Vals=f0Vals;

if gtFlag
    M=abs(M).^2;
end
    
% Spectral Centroid
% inner product of the bin numbers and the magnitude values for each
% divide by the sum of the weights
res.specCent=sum(F.*M)/sum(M);

% Spectral Slope
% compute mean
    mu_x    = mean(M, 1);
% compute index vector
    kmu     = [0:size(M,1)-1] - size(M,1)/2;
% compute slope
    M_slope       = sqrt(M) - repmat(mu_x, size(M,1), 1);
    res.specSlope    = (kmu*M_slope)/(kmu*kmu');
    res.meanSpecSlope=mean(res.specSlope);

% Spectral Flux
% difference spectrum (set first diff to zero)
    afDeltaX    = diff([M(:,1), M],1,2);
% flux
    res.specFlux         = sqrt(sum(afDeltaX.^2))/size(M,1);  
    res.meanspecFlux=mean(res.specFlux);

% Spectral Flatness
% ratio between the geometric and arithmetic means
% this one is probably going to be quite different
    XLog    = log(M+1e-20);
    res.specFlat     = exp(mean(XLog,1)) ./ (mean(M,1));
   
    % avoid NaN for silence frames
    res.specFlat (sum(M,1) == 0) = 0;  
    res.meanspecFlat=mean(res.specFlat);
