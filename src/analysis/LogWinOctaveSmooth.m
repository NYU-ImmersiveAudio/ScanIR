function [ output ] = LogWinOctaveSmooth( Spectrum, Frac )
%LogWinOctaveSmooth Fractional-Octave Smoothing using a log Hanning window
%   Spectrum is a power spectrum to be smoothed
%   Frac is 
%
%   Basic implementations of Fractional-Octave Smoothing use a window
%   function on linear frequency bins, analyzing more frequencies above a
%   target bin than below. This will cause a slight downward frequency shift 
%   in the output spectrum. It is addressed here by using the log(f/f0)
%   inside the Hanning windowing function, effectively weighting the lower
%   octave (with fewer frequency bins) equal to the upper octave (with
%   twice as many bins). This Hanning window is assymmetric in the linear
%   frequency domain, but symmetric in the log frequency domain.
%
%   Written (Mathematica) by Joseph Tylka, 2014
%   Adapted for Matlab by Braxton Boren, 2014

% LogWinOctaveSmooth[Spectrum_, Frac_] := 
%  Module[{Len, Output, n, fL, nL, fH, nH, tempLen, tempWin, 
%    tempNormWin, m, a, b, temp},
if nargin<2 Frac = 1; disp('Default is full octave smoothing'); end

if iscolumn(Spectrum) Spectrum = Spectrum'; end % assure input is a row vector

if (Frac ~= 0)
   Len = length(Spectrum);
   Output = zeros(1,Len); 
   
   for n = 0:(Len - 1)
       
   if n == 2000;
       here = 1;
   end
   
    fL = n*2^(-1/(2*Frac));
    nL = floor(fL);
    fH = n*2^(1/(2*Frac));
    nH = ceil(fH);
    
    %(* Upper limit correction *)
    if (nH > Len - 1) 
     nH = Len - 1;
     nL = floor(n^2/nH);
    end
    if (fH > Len - 1)
     fH = Len - 1;
     fL = floor(n^2/fH);
    end
    
    %(* Window function computation *)
    tempLen = nH - nL + 1;
    tempWin = zeros(1,tempLen); %ConstantArray[0, tempLen];
    if (tempLen == 1)
      tempNormWin = 1;
    else
     m = [nL:1:nH];
     a = m - 0.5;% Lower limit of integral  
     a(a<fL) = fL;
     a(a>fH) = fH;
     b = m + 0.5; %Upper limit of integral 
     b(b<fL) = fL;
     b(b>fH) = fH;

     tempWin = (log2(b./n) - log2(a./n))/2 ... 
         + ( sin(2 * pi * Frac * log2(b./n) ) - sin(2 * pi * Frac * log2(a./n)) )/(4 * pi * Frac);
     tempWin(a==b) = 0;
     tempNormWin = tempWin/sum(tempWin); %normalized weights
    end
    
    %(* Smoothed value computation *)
    temp = Spectrum(nL + 1:nH + 1) .* tempNormWin;
    output(n + 1) = sum(temp);
   end
   output(Len) = output(Len - 1);
   
else
   output = Spectrum;
  
end

